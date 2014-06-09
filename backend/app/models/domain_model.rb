require_relative 'user'
require_relative 'session'
require_relative '../monkeypatches'
require_relative '../message_handlers/message_handler'
require_relative 'message'
require_relative '../my_logger'

class DomainModel
  attr_reader :users, :sessions
  def initialize(options = {})
    @users = options[:users] || UserCollection.new
    @sessions = SessionCollection.new
    @outgoing_messages = OutgoingMessageQueue.new
    @log = MyLogger.new
  end
  def incoming_message(message)
    process(message.symbolize_keys)
  end
  def empty_messages
    @outgoing_messages.clear
  end
  def outgoing_messages(options = {})
    messages = @outgoing_messages
      .filter(options)
      .for_sessions(@sessions)
      .to_a
  end

  private
  def process(message)
    handler = MessageHandler.get_handler(message)
    new_messages = Guard.with_authentication(handler,message,sessions) do
      handler.new(message,self).execute_and_return_response
    end
    @outgoing_messages.add(Array(new_messages))
  end


  class Guard
    def self.with_authentication(handler,message,sessions)
      if authentication_sufficient?(handler,message,sessions)
        yield
      elsif not message.has_key? :auth_token
        AuthTokenRequiredMessage.new
      else
        AuthTokenInvalidMessage.new
      end
    end
    def self.authentication_sufficient?(handler,message,sessions)
      handler.accessible_without_authentication? or
        (message.has_key? :auth_token and
         sessions.find(auth_token: message[:auth_token]))
    end
  end
end

