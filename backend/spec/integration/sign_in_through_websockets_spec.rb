require_relative 'spec_helper'
require 'json'
require_relative '../../app/models/domain_model'

describe "Sign In through websockets" do
  let(:users) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: users) }
  let(:server) { Server.new }
  let(:client) { OmaFon::TestClient.new }
  after(:each) { server.kill }

  context "with existing user" do
    before(:each) { users.create_user(email: "some@email.com",
                                      password: "test") }

    def send_login_request(client,password)
      client.run do |ws|
        ws.send(JSON.dump({type: "user/sign_in",
                           email: "some@email.com",
                           password: password}))
        ws.close_if do |messages,message_types|
          message_types.include? "user/sign_in_successful" or
            message_types.include? "user/sign_in_failed"
        end
      end
    end

    context "with the correct password" do
      let(:password) { "test" }
      it 'returns a successful message' do
        server.start(domain_model)
        send_login_request(client,password)
        expect(client.messages_of_type("user/sign_in_successful").size).to eql 1
        message = client.messages_of_type("user/sign_in_successful").first
        expect(message["auth_token"]).to match /^[a-f0-9]{20}$/
      end
    end

    context "with the wrong password" do
      let(:password) { "wrong" }
      it 'returns a failed message' do
        server.start(domain_model)
        send_login_request(client,password)
        expect(client.messages_of_type("user/sign_in_failed").size).to eql 1
        message = client.messages_of_type("user/sign_in_failed").first
        expect(message).to_not have_key "auth_token"
      end
    end
  end
end
