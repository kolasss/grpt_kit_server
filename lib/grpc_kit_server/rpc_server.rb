# require 'thread'
# require 'serverengine'
# require 'grpc_kit'
# require_relative 'server'
# require_relative 'worker'

# require 'async/io'
# require 'async/io/tcp_socket'

# GRPC contains the General RPC module.
module GrpcKitServer
  # RpcServer hosts a number of services and makes them available on the
  # network.
  class RpcServer
    attr_reader :pool_size
    
    # Default thread pool size is 30
    DEFAULT_POOL_SIZE = 30

    # Deprecated due to internal changes to the thread pool
    DEFAULT_MAX_WAITING_REQUESTS = 20

    # Default poll period is 1s
    DEFAULT_POLL_PERIOD = 1

    DEFAULT_KEEP_ALIVE = 5

    DEFAULT_PORT = 50051

    # Creates a new RpcServer.
    def initialize(
      pool_size: DEFAULT_POOL_SIZE,
      max_waiting_requests: DEFAULT_MAX_WAITING_REQUESTS,
      poll_period: DEFAULT_POLL_PERIOD,
      pool_keep_alive: DEFAULT_KEEP_ALIVE,
      connect_md_proc: nil,
      server_args: {},
      interceptors: [],
      hostname: nil,
      port: DEFAULT_PORT
    )
      # @connect_md_proc = RpcServer.setup_connect_md_proc(connect_md_proc)
      # @max_waiting_requests = max_waiting_requests
      # @poll_period = poll_period
      @pool_size = pool_size
      @pool_keep_alive = pool_keep_alive
      # @pool = Pool.new(@pool_size, keep_alive: pool_keep_alive)
      @run_cond = ConditionVariable.new
      @run_mutex = Mutex.new
      # running_state can take 4 values: :not_started, :running, :stopping, and
      # :stopped. State transitions can only proceed in that order.
      @running_state = :not_started
      # @server = Core::Server.new(server_args)
      @server = build_server(server_args)
      # @interceptors = InterceptorRegistry.new(interceptors)

      @stop_server = false
      @stop_mutex = Mutex.new
      @stop_cond = ConditionVariable.new
      @hostname = hostname
      @port = port

      @handle_services = []
      # @se = ServerEngine.create(Server, Worker, {
      #   # daemonize: true,
      #   # log: 'myserver.log',
      #   # pid_path: 'myserver.pid',
      #   worker_type: 'process',
      #   workers: 4,
      #   bind: @hostname,
      #   port: @port,
      #   handle_services: @handle_services,
      #   grpc_server: @server
      # })
    end

    def add_http2_port(host, *_params)
      @hostname, @port = *host.split(':')
    end

    # stops a running server
    def stop
      GrpcKit.logger.debug('GrpcKit server stopping ==================')
      @run_mutex.synchronize do
        return if @running_state != :running
        transition_running_state(:stopping)

        # @server.force_shutdown
        @server.graceful_shutdown

        if @conn && !@conn.closed?
          GrpcKit.logger.info('GrpcKit conn is open - closing')
          @conn.close
        end

        unless @socket.closed?
          GrpcKit.logger.info('GrpcKit socket is open - closing')
          @socket.close 
        end

        unless @thread.join(5)
          @thread.kill
        end
        transition_running_state(:stopped)
        # @stop_cond.broadcast
      end
    end

    def running_state
      @run_mutex.synchronize do
        return @running_state
      end
    end

    

    def running?
      running_state == :running
    end

    def stopped?
      running_state == :stopped
    end

    # Is called from other threads to wait for #run to start up the server.
    #
    # If run has not been called, this returns immediately.
    #
    # @param timeout [Numeric] number of seconds to wait
    # @return [true, false] true if the server is running, false otherwise
    def wait_till_running(timeout = nil)
      @run_mutex.synchronize do
        @run_cond.wait(@run_mutex, timeout) if @running_state == :not_started
        return @running_state == :running
      end
    end

    # def wait_till_stopped(timeout = nil)
    #   @run_mutex.synchronize do
    #     @stop_cond.wait(@run_mutex, timeout) if @running_state == :stopping
    #     return @running_state == :stopped
    #   end
    # end

    # handle registration of classes
    def handle(service)
      @run_mutex.synchronize do
        unless @running_state == :not_started
          fail 'cannot add services if the server has been started'
        end
        @server.handle(service)
      end
    end

    # runs the server
    def run
      # @stop_server = false
      # # host.split(':')
      # # hostname, port = *@host.split(':')
      # # sock = TCPServer.new(50051)
      # @run_mutex.synchronize do
      #   socket_options = @hostname ? [@hostname, @port] : [@port]
      #   @socket = TCPServer.new(*socket_options)
      #   # fail 'cannot run without registering services' if rpc_descs.size.zero?
      #   # @pool.start
      #   # @server.start
      #   @thread = Thread.new do
      #     # while !@stop_server do
      #     loop do
      #       GrpcKit.logger.info('GrpcKit doing loop ==================')
      #       conn = @socket.accept
      #       @server.run(conn)
      #       GrpcKit.logger.info('GrpcKit doing loop 2 ==================')
      #       break if @stop_mutex.synchronize{ @stop_server }
      #     end
      #     GrpcKit.logger.info('GrpcKit exit loop')
      #     @socket.close unless @socket.closed?
      #     @stop_cond.broadcast
      #   end
      #   transition_running_state(:running)
      #   @run_cond.broadcast
      # end

      # @run_mutex.synchronize do
      #   transition_running_state(:stopped)
      #   GRPC.logger.info("stopped: #{self}")
      #   @server.graceful_shutdown
      #   @thread.join
      # end
      # loop_handle_server_calls
      raise Error, 'hostname or port is nil' unless @hostname && @port

      @run_mutex.synchronize do
        socket_options = @hostname ? [@hostname, @port] : [@port]
        @socket = TCPServer.new(*socket_options)
        @conn = nil
        @thread = Thread.new do
          GrpcKit.logger.info('GrpcKit start of loop')
          loop do
            @conn = @socket.accept
            @server.run(@conn)
          end
          GrpcKit.logger.info('GrpcKit end of loop')
        rescue IOError
          true
        end
        transition_running_state(:running)
        @run_cond.broadcast
      end
    end

    alias_method :run_till_terminated, :run

    private

    # Can only be called while holding @run_mutex
    def transition_running_state(target_state)
      state_transitions = {
        not_started: :running,
        running: :stopping,
        stopping: :stopped
      }
      if state_transitions[@running_state] == target_state
        @running_state = target_state
      else
        fail "Bad server state transition: #{@running_state}->#{target_state}"
      end
    end

    # initialize(interceptors: [], shutdown_timeout: 30, min_pool_size: nil, max_pool_size: nil, settings: [], max_receive_message_size: nil, max_send_message_size: nil)
    def build_server(server_args)
      GrpcKit::Server.new(**server_params(server_args))
    end

    def server_params(server_args = {})
      server_args.to_h.merge(
        # interceptors: interceptors,
        shutdown_timeout: @pool_keep_alive,
        # min_pool_size: min_pool_size,
        max_pool_size: @pool_size,
      )
    end
  end
end
