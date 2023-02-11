# frozen_string_literal: true

require 'grpc_kit'

module GrpcKitServer
  module Worker
    # def initialize
    #   @grpc_server = build_server()
    # end
    def initialize
      # @stop_flag = ServerEngine::BlockingFlag.new
      @socket_manager = ServerEngine::SocketManager::Client.new(server.socket_manager_path)
      @stop_flag = ServerEngine::BlockingFlag.new
    end

    def run
      @grpc_server = GrpcKit::Server.new
      config[:handle_services].each { |service| @grpc_server.handle(service) }

      lsock = @socket_manager.listen_tcp(config[:bind], config[:port])

      # until @stop
      until @stop_flag.wait_for_set(1.0)
        # you should use Cool.io or EventMachine actually
        # c = server.sock.accept
        # c.write "Awesome work!"
        # c.close
        GrpcKit.logger.info('GrpcKit starting worker ==================')
        # conn = server.sock.accept
        @conn = lsock.accept
        # @grpc_server.run(conn)
        # server.grpc_server.run(conn)
        # config[:grpc_server].run(conn)
        @grpc_server.run(@conn)
      end

      # @grpc_server.graceful_shutdown
      # conn.close unless conn.closed?
    end
  
    def stop
      GrpcKit.logger.info('GrpcKit stopping worker ==================')
      # @stop = true
      @stop_flag.set!
      # @grpc_server.force_shutdown
      @grpc_server.graceful_shutdown
      @conn.close if @conn && !@conn.closed?
    end

    private

    def build_server()
      # GrpcKit::Server.new(**server_params(server_args))
      GrpcKit::Server.new
    end

    def server_params(server_args = {})
      server_args.merge(
        # interceptors: interceptors,
        shutdown_timeout: @pool_keep_alive,
        # min_pool_size: min_pool_size,
        max_pool_size: @pool_size,
      )
    end
  end
end
