require 'securerandom'

class SessionCollection
  def initialize(collection = {})
    @collection = collection
  end
  def create_session(options)
    session = Session.new(options)
    @collection[session.auth_token] = session
    session
  end
  def find(options)
    if auth_token = options[:auth_token]
      @collection[auth_token]
    end
  end
  def user_emails
    sessions.map(&:user_email)
  end
  def without(user)
    new_collection = @collection.reject do |auth_token,session|
      session.user == user
    end
    SessionCollection.new(new_collection)
  end
  def online_statuses
    sessions.map(&:hash_for_public_consumption)
  end
  private
  def sessions
    @collection.values
  end
end

class Session
  attr_reader :user, :auth_token, :status

  def initialize(options = {})
    @user = options[:user]
    @auth_token = SecureRandom.hex(10)
    @status = :online
  end

  def user_email
    @user.email
  end

  def hash_for_public_consumption
    {user_email: user_email,
     status: status}
  end
end
