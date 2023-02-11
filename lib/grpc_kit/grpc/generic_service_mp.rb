# frozen_string_literal: true

require 'grpc_kit/grpc/generic_service.rb'
require 'grpc_kit/grpc/dsl'
require 'grpc_kit/grpc/dsl_mp'

module GrpcKit
  module Grpc
    module GenericService
      def self.included(obj)
        obj.extend(GrpcKit::Grpc::Dsl)
        obj.extend(GrpcKit::Grpc::DslMp)
      end
    end
  end
end
