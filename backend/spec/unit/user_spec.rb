require_relative '../../app/models/user'

describe UserCollection do
  subject(:collection) { UserCollection.new }
  describe '#create_user' do
    it 'adds a user' do
      expect(collection.size).to eql 0
      collection.create_user(email: "some@email.com", password: "supersecret")
      expect(collection.size).to eql 1
    end
    it 'does not let me create two Users with the same email' do
      collection.create_user(email: "some@email.com", password: "supersecret")
      expect do
        collection.create_user(email: "some@email.com", password: "supersecret")
      end.to raise_error
    end
  end
end

describe User do

end
