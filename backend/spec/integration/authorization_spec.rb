require_relative 'spec_helper'
require 'json'
require_relative '../../app/models/domain_model'

describe "Sign In" do
  let(:users) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: users) }


  context "with existing user" do
    before(:each) { users.create_user(email: "some@email.com",
                                      password: "test") }
    it 'returns a successful message' do
      server = Server.new(:test)
      server.domain_model = domain_model
      server_thread = Thread.new { server.run }
      client = OmaFon::TestClient.new
      client.run do |ws|
        start_time = Time.new
        ws.send(JSON.dump({type: "user/sign_in",
                           email: "some@email.com",
                           password: "test"}))
        stop_it = proc {
          if Time.new - start_time > 0.1
            ws.close
          else
            EM.next_tick &stop_it
          end
        }
        EM.next_tick &stop_it
      end
      expect(client.messages_of_type("user/sign_in_successful").size).to eql 1
      Thread.kill(server_thread)
    end

    it 'returns a failed message' do
      server = Server.new(:test)
      server.domain_model = domain_model
      server_thread = Thread.new { server.run }
      client = OmaFon::TestClient.new
      client.run do |ws|
        start_time = Time.new
        ws.send(JSON.dump({type: "user/sign_in",
                           email: "some@email.com",
                           password: "wrong"}))
        stop_it = proc {
          if Time.new - start_time > 0.1
            ws.close
          else
            EM.next_tick &stop_it
          end
        }
        EM.next_tick &stop_it
      end
      expect(client.messages_of_type("user/sign_in_failed").size).to eql 1
      Thread.kill(server_thread)
    end


  end

end
