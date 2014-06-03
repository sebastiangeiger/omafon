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

  describe 'an unknown message arrives' do
    it 'no type given raises an error' do
      expect {
        domain_model.incoming_message({})
      }.to raise_error('Type of message is missing')
    end
    it 'unknown type raises an error' do
      expect {
        domain_model.incoming_message({type: 'some/type_here'})
      }.to raise_error('Handler MessageHandler::Some::TypeHere not defined')
    end
  end
end
