require_relative 'collection'

class UserCollection < Collection
  validates_uniqueness_of :email

  def create_user(options)
    collection << User.new(options)
  end

  def authenticate(options)
    user = collection.select{|user| user.email == options[:email]}.first
    if user and user.password_matches?(options[:password])
      user
    else
      nil
    end
  end
end

class User
  attr_accessor :email, :password, :password_hash, :salt

  def initialize(options = {})
    @email = options[:email]
    @password = options[:password]
    hash_password!
  end

  def password_matches?(password)
    @password_hash == hash_password(password,@salt)
  end

  private
  def hash_password!
    @salt = SecureRandom.hex(10)
    @password_hash = hash_password(@password,@salt)
    @password = nil
  end
  def hash_password(password,salt)
    digest = OpenSSL::Digest::SHA1.new
    digest.hexdigest(password + salt)
  end
end
