require_relative '../../app/models/domain_model'

describe DomainModel do
  let(:user_collection) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: user_collection) }

  describe 'Sign in procedure' do
    let(:sign_in_message) do
      { type: 'user/sign_in',
        email: 'some@email.com',
        password: password }
    end
    before(:each) do
      user_collection.create_user(email: 'some@email.com',
                                  password: 'password')
    end

    context 'with the correct password' do
      let(:password) { 'password' }
      it 'signs in a user' do
        domain_model.incoming_message(sign_in_message)
        expect(domain_model.outgoing_messages.size).to eql 1
        message = domain_model.outgoing_messages.first
        expect(message[:type]).to eql 'user/sign_in_successful'
        expect(message).to have_key :auth_token
      end
    end
    context 'with the wrong password' do
      let(:password) { 'wrong_password' }
      it 'signs in a user' do
        domain_model.incoming_message(sign_in_message)
        expect(domain_model.outgoing_messages.size).to eql 1
        message = domain_model.outgoing_messages.first
        expect(message[:type]).to eql 'user/sign_in_failed'
        expect(message).to_not have_key :auth_token
      end
    end
  end

  describe 'protecting a secret' do
    class MessageHandler::TestSecret < MessageHandler::AbstractHandler
      def execute
        respond({type: 'secret_revealed'})
      end
    end
    context 'without an auth token' do
      let(:retrive_secret_message) do
        { type: 'test_secret' }
      end
      it 'does not reveal the secret' do
        domain_model.incoming_message(retrive_secret_message)
        expect(domain_model.outgoing_messages.size).to eql 1
        message = domain_model.outgoing_messages.first
        expect(message[:type]).to eql 'error/auth_token_required'
      end
    end
    context 'when I am signed in' do
      let(:email) { 'some@email.com' }
      let(:password) { 'password' }
      let(:sign_in_message) do
        { type: 'user/sign_in',
          email: email,
          password: password }
      end
      let(:valid_auth_token) do
        domain_model.incoming_message(sign_in_message)
        auth_token = domain_model.outgoing_messages.first[:auth_token]
        domain_model.empty_messages
        auth_token
      end
      let(:invalid_auth_token) do
        valid_auth_token.reverse
      end
      before(:each) do
        user_collection.create_user(email: email,
                                    password: password)
      end
      it 'does reveal the secret when given the correct auth_token' do
        domain_model.incoming_message({type: 'test_secret', auth_token: valid_auth_token})
        expect(domain_model.outgoing_messages.size).to eql 1
        message = domain_model.outgoing_messages.first
        expect(message[:type]).to eql 'secret_revealed'
      end
      it 'does not reveal the secret when given the wrong auth_token' do
        domain_model.incoming_message({type: 'test_secret', auth_token: invalid_auth_token})
        expect(domain_model.outgoing_messages.size).to eql 1
        message = domain_model.outgoing_messages.first
        expect(message[:type]).to eql 'error/auth_token_invalid'
      end
    end
  end
end
