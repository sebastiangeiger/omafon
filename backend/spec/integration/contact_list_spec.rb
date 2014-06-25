require_relative 'spec_helper'
require_relative '../../app/models/domain_model'

describe "The contact list" do
  let(:user_collection) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: user_collection) }
  let(:connection_a) { domain_model.create_connection }
  let(:connection_b) { domain_model.create_connection }

  before(:each) do
    user_collection.create_user(email: 'user_a@email.com',
                                password: 'password')
    user_collection.create_user(email: 'user_b@email.com',
                                password: 'password')
  end

  def sign_in(connection,user)
    message = { type: 'user/sign_in',
                email: "#{user.to_s}@email.com",
                password: 'password' }
    connection.incoming_message(message)
  end

  context 'when user_a signs in and user_b is already online' do
    before(:each) do
      sign_in(connection_b, :user_b)
      connection_b.empty_messages
      sign_in(connection_a, :user_a)
    end

    describe 'the user/status_changed notification for user_b' do
      let(:status_changed) do
        connection_b.
          outgoing_messages(type:"user/status_changed").
          first
      end
      it 'is sent' do
        expect(status_changed).to_not be_nil
      end
      it 'includes users A email address' do
        expect(status_changed[:user_email]).to eql "user_a@email.com"
        expect(status_changed[:new_status]).to eql "online"
      end
    end

    describe 'the user/all_statuses notification for user_a' do
      let(:all_statuses) do
        connection_a
          .outgoing_messages(type:"user/all_statuses")
          .first
      end
      it 'is sent to user A' do
        expect(all_statuses).to_not be_nil
      end
      it 'includes users b contact' do
        user_b = {user_email: 'user_b@email.com', status: :online}
        expect(all_statuses[:users]).to include user_b
      end
      it 'does not include user a' do
        user_a = {user_email: 'user_a@email.com', status: :online}
        expect(all_statuses[:users]).to_not include user_a
      end
    end
  end

  context 'when user_a and user_b are both online, and then user_b goes offline' do
    before(:each) do
      sign_in(connection_b, :user_b)
      connection_b.empty_messages
      sign_in(connection_a, :user_a)
      connection_a.empty_messages
      connection_b.close
    end

    describe 'the user/status_changed notification for user_a' do
      let(:status_changed) do
        connection_a.
          outgoing_messages(type:"user/status_changed").
          first
      end
      it 'is sent' do
        expect(status_changed).to_not be_nil
      end
      it 'includes users B email address' do
        expect(status_changed[:user_email]).to eql "user_b@email.com"
        expect(status_changed[:new_status]).to eql "offline"
      end
    end
  end
end
