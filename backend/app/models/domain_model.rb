require_relative 'user'

class HashHelper
  def self.symbolize_keys(hash)
    hash.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
  end
end
class DomainModel
  attr_reader :outgoing_messages, :users
  def initialize(options = {})
    @users = options[:users] || UserCollection.new
    @outgoing_messages = []
  end
  def incoming_message(message)
    message = HashHelper.symbolize_keys(message)
    if message[:type] == "user/sign_in"
      handler = MessageHandler::User::SignIn.new(message,self)
      @outgoing_messages += handler.execute
    else
      raise "Don't know this message type"
    end
  end
  def empty_messages
    @outgoing_messages.clear
  end
end

module MessageHandler
  module User
    class SignIn
      def initialize(message,domain_model)
        @message = message
        @domain_model = domain_model
      end
      def execute
        user = users.authenticate(email: message[:email],
                                  password: message[:password])
        if user
          [{type: "user/sign_in_successful",
            auth_token: SecureRandom.hex(10)}]
        else
          [{type: "user/sign_in_failed"}]
        end
      end
      private
      def message; @message; end
      def users; @domain_model.users; end
    end
  end
end
