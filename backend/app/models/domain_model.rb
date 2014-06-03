require_relative 'user'

class DomainModel
  attr_reader :outgoing_messages
  def initialize(options = {})
    @users = options[:users] || UserCollection.new
    @outgoing_messages = []
  end
  def incoming_message(message)
    if message["type"] == "user/sign_in"
      user = @users.authenticate(email: message["email"],
                                 password: message["password"])
      if user
        @outgoing_messages << {type: "user/sign_in_successful",
                               auth_token: SecureRandom.hex(10)}
      else
        @outgoing_messages << {type: "user/sign_in_failed"}
      end
    else
      raise "Don't know this message type"
    end
  end
  def empty_messages
    @outgoing_messages.clear
  end
end
