require_relative 'user'
require_relative '../monkeypatches'

class DomainModel
  attr_reader :outgoing_messages, :users
  def initialize(options = {})
    @users = options[:users] || UserCollection.new
    @outgoing_messages = []
  end
  def incoming_message(message)
    message = message.symbolize_keys
    handler = MessageHandler.get_handler(message)
    @outgoing_messages += handler.new(message,self).execute
  end
  def empty_messages
    @outgoing_messages.clear
  end
end

module MessageHandler
  def self.get_handler(message)
    if message and message[:type]
      module_name = self.message_type_to_module_name(message[:type])
      begin
        module_name.reduce(Module, :const_get)
      rescue NameError => e
        raise "Handler #{module_name.join('::')} not defined"
      end
    else
      raise 'Type of message is missing'
    end
  end

  private
  def self.message_type_to_module_name(type)
    camelized_type = type.split('/').map{|mod| mod.camelize}
    ['MessageHandler'] + camelized_type
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
          [{type: 'user/sign_in_successful',
            auth_token: SecureRandom.hex(10)}]
        else
          [{type: 'user/sign_in_failed'}]
        end
      end
      private
      def message; @message; end
      def users; @domain_model.users; end
    end
  end
end
