require_relative '../../app/models/user'

describe UserCollection do
  subject(:collection) { UserCollection.new }
  describe '#create_user' do
    it 'adds a user' do
      expect(collection.size).to eql 0
      collection.create_user(email: "some@email.com", password: "supersecret")
      expect(collection.size).to eql 1
    end
    it 'passes the arguments on to the user' do
      expect(User).to receive(:new).with(email: "some@email.com", password: "supersecret")
      collection.create_user(email: "some@email.com", password: "supersecret")
    end
  end
end

describe User do

end
