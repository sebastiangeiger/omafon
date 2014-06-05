require_relative 'user'
require_relative 'session'
require_relative '../monkeypatches'
require_relative '../message_handlers/message_handler'

class DomainModel
  attr_reader :outgoing_messages, :users, :sessions
  def initialize(options = {})
    @users = options[:users] || UserCollection.new
    @sessions = SessionCollection.new
    @outgoing_messages = []
  end
  def incoming_message(message)
    process(message.symbolize_keys)
  end
  def empty_messages
    @outgoing_messages.clear
  end

  private
  def process(message)
    handler = MessageHandler.get_handler(message)
    new_messages = Guard.with_authentication(handler,message,sessions) do
      handler.new(message,self).execute_and_return_response
    end
    @outgoing_messages += new_messages
  end


  class Guard
    def self.with_authentication(handler,message,sessions)
      if authentication_sufficient?(handler,message,sessions)
        yield
      elsif not message.has_key? :auth_token
        [{type: "error/auth_token_required"}]
      else
        [{type: "error/auth_token_invalid"}]
      end
    end
    def self.authentication_sufficient?(handler,message,sessions)
      handler.accessible_without_authentication? or
        (message.has_key? :auth_token and
         sessions.find(auth_token: message[:auth_token]))
    end
  end
end

