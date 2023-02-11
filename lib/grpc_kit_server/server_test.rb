# frozen_string_literal: true

require 'serverengine'
require 'async/io'
require 'async/io/tcp_socket'

module GrpcKitServer
  class ServerTest
    attr_reader :sock, :server, :conn, :thread, :lsock, :stop_flag

    def initialize
      # @stop_flag = false
      @run_cond = ConditionVariable.new
      @run_mutex = Mutex.new
      @stop_flag = ServerEngine::BlockingFlag.new
      # @queue = Queue.new
      # @socket_manager_path = ServerEngine::SocketManager::Server.generate_path
      # @socket_manager_server = ServerEngine::SocketManager::Server.open(@socket_manager_path)
    end

    def run
      # @stop_flag = false
      # @stop_flag.reset!
      @sock = TCPServer.new(50051)
      @server = GrpcKit::Server.new
      # server.handle(GreeterServer.new)
      # @socket_manager = ServerEngine::SocketManager::Client.new(@socket_manager_path)
      # @lsock = @socket_manager.listen_tcp('0.0.0.0', 50051)
      # @lsock.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

      @thread = Thread.new do
        GrpcKit.logger.info('GrpcKit start of loop')
        # until @run_mutex.synchronize { @stop_flag } do
        # until @stop_flag do
        # loop do
        # @conn = @lsock.accept
        @conn = @sock.accept
        @server.run(@conn)
        # begin
        #   until @stop_flag.set?
        #     # Thread.stop if @stop_flag
        #     # break if pop_queue_safe

        #     GrpcKit.logger.info('GrpcKit loop')
        #     # break if @sock.closed?
        #     # @conn = @sock.accept
        #     # @conn = @sock.accept_nonblock(exception: false)
        #     # next if @conn == :wait_readable
        #     @conn = @lsock.accept
        #     @server.run(@conn)

        #     # result = IO.select([@sock])
        #     # result[0].each do |socket|
        #     #   @server.run(socket.accept)
        #     # end
        #   end
        GrpcKit.logger.info('GrpcKit end of loop')
        rescue IOError

        # end
        # @server.graceful_shutdown
      end
      # until @stop_flag.wait_for_set(1.0)
      # until @stop_flag.set?
      #   @conn = @sock.accept
      #   @server.run(@conn)
      # end
      # @run_cond.signal
      # endpoint = Async::IO::Endpoint.tcp('0.0.0.0', 50051)
      
      # Async do
      #   @async_server = Async do |task|
      #     GrpcKit.logger.info('GrpcKit start of loop')
      #     # This is a synchronous block within the current task:
      #     endpoint.accept do |client|
      #       @server.run(client)
      #     end
      #   end
      # end


      # @async_server = Async::IO::TCPServer.new('0.0.0.0', 50051)
      # @reactor = Async::Reactor.new
      # @reactor.async do
      #   Async do |task|
      #     GrpcKit.logger.info('GrpcKit start of loop')
      #     # This is a synchronous block within the current task:
      #     @async_server.accept do |client|
      #       @server.run(client)
      #     end
      #   end
      # end
      # GrpcKit.logger.info('GrpcKit end of loop')
    # ensure
      # @lsock.close if @lsock
      # @sock.close if @sock

      # Async do |task|
      #   server = Async::IO::TCPServer.new('0.0.0.0', 50051)
        
      #   reactor = Async::Reactor.new
      #   reactor.async do
      #     loop do
      #       client, address = server.accept
            
      #       task.async do
      #         while buffer = client.gets
      #           client.puts(buffer)
      #         end
              
      #         client.close
      #       end
      #     end
      #   end
      # end
    end

    def stop
      # @run_mutex.synchronize do
      #   @stop_flag = true
      # end
      # @stop_flag = true
      # @stop_flag.set!
      # @queue << true
      # @thread.kill.join
      # @thread.wakeup
      # @thread.join

      # @run_cond.wait(@run_mutex)
      # sleep(1)
      # @async_server.stop

      # @reactor.close
      # @async_server.close
      @server.graceful_shutdown

      unless @sock.closed?
        GrpcKit.logger.info('GrpcKit sock is open - closing')
        @sock.close 
      end
      # @lsock.close
      # @socket_manager_server.close
    end

    # def pop_queue_safe
    #   @queue.pop(true)
    # rescue ThreadError
    #   false
    # end
  end
end
