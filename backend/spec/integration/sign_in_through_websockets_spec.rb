require_relative 'spec_helper'
require 'json'
require_relative '../../app/models/domain_model'

describe "Sign In through websockets" do
  let(:users) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: users) }
  let(:server) { Server.new }
  after(:each) { server.kill }

  context "with existing user" do
    let(:client) { OmaFon::TestClient.new }
    before(:each) { users.create_user(email: "some@email.com",
                                      password: "test") }

    def send_login_request(client,password)
      client.run do |ws,logger|
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

  context "with one user already logged in" do
    let(:user_a) { OmaFon::TestClient.new(name: "User A", verbose: false) }
    let(:user_b) { OmaFon::TestClient.new(name: "User B", verbose: false) }
    before(:each) do
      users.create_user(email: "user_a@email.com", password: "password_a")
      users.create_user(email: "user_b@email.com", password: "password_b")
    end

    def send_login_request(client,client_name,password,end_message)
      client.run do |ws,log|
        message = {type: "user/sign_in",
                   email: "#{client_name.to_s}@email.com",
                   password: password}
        log.debug("Sending #{message}")
        ws.send(JSON.dump(message))
        ws.close_if do |messages,message_types|
          message_types.include? end_message or
            message_types.include? "user/sign_in_failed"
        end
      end
    end

    it 'introduces the users to each other' do
      server.start(domain_model)
      t1 = Thread.new do
        send_login_request(user_a, :user_a, "password_a", "user/status_changed")
      end
      sleep(1)
      t2 = Thread.new do
        send_login_request(user_b, :user_b, "password_b", "user/all_statuses")
      end
      sleep(1)
      expect(user_b.messages_of_type("user/all_statuses").size).to eql 1
      expect(user_a.messages_of_type("user/all_statuses").size).to eql 1
      expect(user_b.messages_of_type("user/status_changed").size).to eql 0
      expect(user_a.messages_of_type("user/status_changed").size).to eql 1
    end

  end
end
