require_relative 'spec_helper'

describe "TestClient" do
  let(:domain_model) { DomainModel.new }

  let(:server) { Server.new }
  after(:each) { server.kill }

  it 'connects to the server' do
    server.start(domain_model)
    client = OmaFon::TestClient.new
    client.run do |ws|
      ws.close
    end
    expect(client.closed?).to be_true
    expect(client.connected?).to be_false
    expect(client.was_connected?).to be_true
  end
end