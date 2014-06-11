require_relative 'user'
require_relative 'session'
require_relative '../monkeypatches'
require_relative '../message_handlers/message_handler'
require_relative 'message'
require_relative '../message_handlers/message_handler_executor'
require_relative '../my_logger'

class DomainModel
  attr_reader :users, :sessions, :authenticator
  def initialize(options = {})
    @users = options[:users] || UserCollection.new
    @sessions = SessionCollection.new
    @authenticator = Authenticator.new(@sessions)
    @outgoing_messages = OutgoingMessageQueue.new
    @log = MyLogger.new
  end
  def incoming_message(message)
    process_incoming_message(message.symbolize_keys)
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
  def process_incoming_message(message)
    handler = MessageHandler.get_handler(message)
    executor = MessageHandlerExecutor.new(handler,message,self)
    executor.execute!
    @outgoing_messages.add(executor.outgoing_messages)
  end

end

