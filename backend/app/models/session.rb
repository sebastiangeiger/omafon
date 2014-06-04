require 'securerandom'

class SessionCollection
  def initialize
    @collection = {}
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
end

class Session
  attr_reader :user, :auth_token

  def initialize(options = {})
    @user = options[:user]
    @auth_token = SecureRandom.hex(10)
  end
end
