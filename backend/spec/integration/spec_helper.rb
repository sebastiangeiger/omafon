require_relative 'test_client'
require_relative '../../app/server.rb'
require 'websocket-eventmachine-client'
require 'pry'

def start_and_stop_server
  around(:each) do |example|
    server = Server.new(:test)
    server_thread = Thread.new { server.run }
    example.run
    Thread.kill(server_thread)
  end
end

