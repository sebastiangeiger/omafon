require_relative 'user'
require_relative '../monkeypatches'
require_relative '../message_handlers/message_handler'

class DomainModel
  attr_reader :outgoing_messages, :users
  def initialize(options = {})
    @users = options[:users] || UserCollection.new
    @outgoing_messages = []
  end
  def incoming_message(message)
    message = message.symbolize_keys
    handler = MessageHandler.get_handler(message)
    new_messages = Guard.with_authentication(handler,message) do
      handler.new(message,self).execute
    end
    @outgoing_messages += new_messages
  end
  def empty_messages
    @outgoing_messages.clear
  end


  class Guard
    def self.with_authentication(handler,message)
      if authentication_sufficient?(handler,message)
        yield
      else
        [{type: "error/auth_token_required"}]
      end
    end
    def self.authentication_sufficient?(handler,message)
      if handler.accessible_without_authentication?
        true
      elsif message.has_key? :auth_token
        true
      else
        false
      end
    end
  end
end

