# frozen_string_literal: true

module GrpcKitServer
  module Server
    attr_reader :sock, :socket_manager_path

    # def initialize
    #   # @grpc_server = build_server()
    # end

    def before_run
      # @sock = TCPServer.new(config[:bind], config[:port])
      @socket_manager_path = ServerEngine::SocketManager::Server.generate_path
      @socket_manager_server = ServerEngine::SocketManager::Server.open(@socket_manager_path)
      GrpcKit.logger.info('GrpcKit starting server ------------------')
      
      # config[:handle_services].each { |service| @grpc_server.handle(service) }
    end

    def after_run
      GrpcKit.logger.info('GrpcKit stopping server ------------------')
      # @sock.close
      @socket_manager_server.close
    end

    private

    # def build_server()
    #   # GrpcKit::Server.new(**server_params(server_args))
    #   GrpcKit::Server.new
    # end
  end
end
