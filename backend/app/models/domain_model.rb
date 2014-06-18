require_relative 'user'
require_relative 'session'
require_relative 'connection'
require_relative '../monkeypatches'
require_relative '../message_handlers/message_handler'
require_relative 'outgoing_message_queue'
require_relative '../message_handlers/message_handler_executor'
require_relative '../my_logger'

class DomainModel
  attr_reader :users, :sessions, :authenticator, :connections
  def initialize(options = {})
    @users = options[:users] || UserCollection.new
    @sessions = SessionCollection.new
    @connections = ConnectionCollection.new
    @authenticator = Authenticator.new(@sessions)
    @outgoing_messages = OutgoingMessageQueue.new(@sessions,@connections)
    @log = MyLogger.new
  end
  def incoming_message(message,connection)
    process_incoming_message(message.symbolize_keys,connection)
  end
  def empty_messages
    @outgoing_messages.clear
  end
  def create_connection
    @connections.create_connection(self)
  end

  private
  def process_incoming_message(message,connection)
    handler = MessageHandler.get_handler(message)
    executor = MessageHandlerExecutor.new(handler,message,connection,self)
    executor.execute!
    @outgoing_messages.add(executor.outgoing_messages)
    @outgoing_messages.deliver_messages!
  end

end

