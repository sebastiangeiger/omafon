require_relative 'test_client'
require_relative '../../app/server.rb'
require_relative '../../app/models/domain_model'
require 'websocket-eventmachine-client'
require 'pry'

def start_and_stop_server
  around(:each) do |example|
    server = Server.new(:test)
    server.domain_model = DomainModel.new
    server_thread = Thread.new { server.run }
    example.run
    Thread.kill(server_thread)
  end
end

