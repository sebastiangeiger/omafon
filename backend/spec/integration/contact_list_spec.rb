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
          outgoing_messages.
          select{|msg| msg[:type] == "user/status_changed"}.
          first
      end
      it 'sends a status changed notification' do
        message_types = domain_model.outgoing_messages.map{|msg| msg[:type]}
        expect(message_types).to include "user/status_changed"
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
end
