require_relative 'spec_helper'

describe "TestClient" do
  start_and_stop_server

  it 'connects to the server' do
    client = OmaFon::TestClient.new
    client.run do |ws|
      ws.close
    end
    expect(client.closed?).to be_true
    expect(client.connected?).to be_false
    expect(client.was_connected?).to be_true
  end
end
