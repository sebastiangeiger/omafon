require_relative 'spec_helper'
require_relative '../../app/models/domain_model'

describe DomainModel do
  let(:user_collection) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: user_collection) }

  def sign_in(domain_model,user)
    message = { type: 'user/sign_in',
                email: "#{user.to_s}@email.com",
                password: 'password' }
    domain_model.incoming_message(message)
  end
  describe 'Signing user A in notifies user B' do

    before(:each) do
      user_collection.create_user(email: 'user_a@email.com',
                                  password: 'password')
      user_collection.create_user(email: 'user_b@email.com',
                                  password: 'password')
    end

    context 'User B signs in, then user A' do
      before(:each) do
        sign_in(domain_model, :user_b)
        domain_model.empty_messages
        sign_in(domain_model, :user_a)
      end
      let(:status_message) do
        domain_model.
          outgoing_messages(type:"user/status_changed").
          first
      end
      it 'sends a status changed notification' do
        expect(status_message).to_not be_nil
        expect(status_message[:type]).to eql "user/status_changed"
      end
      it 'includes users A email address' do
        expect(status_message[:user_email]).to eql "user_a@email.com"
        expect(status_message[:new_status]).to eql "online"
      end
      it 'sends that notification to everyone except the current user' do
        expect(status_message).to_not have_key :recipients_exclude
        expect(status_message[:recipients]).to eql ["user_b@email.com"]
      end
    end
  end
  describe 'Signing user A sends him all contact statuses' do

    before(:each) do
      user_collection.create_user(email: 'user_a@email.com',
                                  password: 'password')
      user_collection.create_user(email: 'user_b@email.com',
                                  password: 'password')
    end

    context 'User B signs in, then user A' do
      before(:each) do
        sign_in(domain_model, :user_b)
        domain_model.empty_messages
        sign_in(domain_model, :user_a)
      end
      let(:contact_list_message) do
        domain_model
          .outgoing_messages(type:"user/all_statuses")
          .first
      end
      it 'sends the all_statuses message to user A' do
        expect(contact_list_message[:recipients]).to eql ["user_a@email.com"]
      end
      it 'includes users b contact' do
        user_b = {user_email: 'user_b@email.com', status: :online}
        expect(contact_list_message[:users]).to include user_b
      end
      it 'does not include user a' do
        user_a = {user_email: 'user_a@email.com', status: :online}
        expect(contact_list_message[:users]).to_not include user_a
      end
    end
  end
end
