require_relative 'spec_helper'
require_relative '../../app/models/domain_model'

describe DomainModel do
  let(:user_collection) { UserCollection.new }
  let(:domain_model) { DomainModel.new(users: user_collection) }

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
