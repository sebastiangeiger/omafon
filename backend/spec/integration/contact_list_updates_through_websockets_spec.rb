require_relative 'spec_helper'
require 'json'
require_relative '../../app/models/domain_model'

describe "Contact list updates through websockets" do
  let(:users) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: users) }
  let(:server) { Server.new }
  let(:user_a) { OmaFon::TestClient.new }
  let(:user_b) { OmaFon::TestClient.new }
  after(:each) { server.kill }

  context "with existing user" do
    before(:each) do
      users.create_user(email: "user_a@email.com",
                        password: "useraspassword")
      users.create_user(email: "user_b@email.com",
                        password: "userbspassword")
    end


    it 'works correctly' do
      server.start(domain_model)
      user_a.run do |ws|
        ws.send(JSON.dump({type: "user/sign_in",
                           email: "user_a@email.com",
                           password: "useraspassword"}))
        ws.close_if do |messages,message_types|
          message_types.include? "user/all_statuses"
        end
      end
      user_b.run do |ws|
        ws.send(JSON.dump({type: "user/sign_in",
                           email: "user_a@email.com",
                           password: "useraspassword"}))
        ws.close_if do |messages,message_types|
          message_types.include? "user/all_statuses"
        end
      end
      message = user_a.messages_of_type("user/all_statuses").first
      expect(message["users"]).to eql []
    end
  end


end
