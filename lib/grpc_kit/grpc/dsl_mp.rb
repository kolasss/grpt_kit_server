# frozen_string_literal: true

module GrpcKit
  module Grpc
    # Monkey-patch for rpc_stub_class, implements interaface of GRPC gem's same method
    # WARNING: immediately trying to connect unlike grpc gem
    module DslMp
      def rpc_stub_class
        klass = super

        klass.class_eval do
          def initialize(host, creds, **kw)
            @rpcs = {}
            hostname, port = *host.split(':')
            sock = TCPSocket.new(hostname, port)
            super(sock, **kw)
          end
        end
        klass
      end
    end
  end
end
