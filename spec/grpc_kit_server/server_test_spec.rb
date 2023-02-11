# frozen_string_literal: true

require 'grpc_kit_server/server_test'

RSpec.describe GrpcKitServer::ServerTest do
  it "works" do
    GrpcKit.logger = Logger.new($stdout)
    s = GrpcKitServer::ServerTest.new

    s.run
    sleep(1)
    s.stop
    expect(s.sock&.closed?).to eq(true)
  end
end
