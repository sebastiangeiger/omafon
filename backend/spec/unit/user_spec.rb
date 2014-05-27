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
  describe '#authenticate' do
    before(:each) do
      collection.create_user(email: "some@email.com", password: "test")
    end
    it 'returns a valid user when the password is correct' do
      user = collection.authenticate(email: "some@email.com",
                                     password: "test")
      expect(user.email).to eql "some@email.com"
    end
    it 'returns nil when the email does not exist' do
      user = collection.authenticate(email: "someonelese@email.com",
                                     password: "test")
      expect(user).to be_nil
    end
    it 'returns nil when the password is incorrect' do
      user = collection.authenticate(email: "some@email.com",
                                     password: "test1")
      expect(user).to be_nil
    end
  end
end

describe User do
  let(:valid_user) { User.new(email: "some@email.com", password: "test") }
  describe '#email' do
    it 'sets the email' do
      expect(valid_user.email).to eql "some@email.com"
    end
  end
  describe '#password' do
    before(:each) {
      SecureRandom.stub(:hex).and_return "50a2ca75ce886df16a38"
    }
    it 'sets a salt' do
      expect(valid_user.salt).to eql "50a2ca75ce886df16a38"
    end
    it 'hashes the password' do
      expect(valid_user.password_hash).to eql "041cff6d6c242e7bf594e5678080d234f6c8b631"
    end
    it 'unsets the password' do
      expect(valid_user.password).to be_nil
    end
  end
  describe '#password_matches?' do
    it 'returns true with correct password' do
      expect(valid_user.password_matches?("test")).to eql true
    end
    it 'returns false with correct password' do
      expect(valid_user.password_matches?("test1")).to eql false
    end
  end

end
