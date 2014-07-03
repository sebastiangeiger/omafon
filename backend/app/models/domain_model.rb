require_relative 'user'
require_relative 'session'
require_relative 'connection'
require_relative '../monkeypatches'
require_relative '../message_handlers/message_handler'
require_relative '../state_change_handlers/state_change_handler'
require_relative 'postmaster'
require_relative '../message_handlers/message_handler_executor'
require_relative '../my_logger'

class DomainModel
  attr_reader :users, :sessions, :authenticator, :connections
  def initialize(options = {})
    @users = options[:users] || UserCollection.new
    @sessions = SessionCollection.new
    @connections = ConnectionCollection.new
    @authenticator = Authenticator.new(@sessions)
    @postmaster = Postmaster.new(@sessions,@connections)
    @log = MyLogger.new
    register_state_change_handlers!
  end
  def incoming_message(message,connection)
    process_incoming_message(message.symbolize_keys,connection)
  end
  def create_connection
    @connections.create_connection(self)
  end

  private
  def process_incoming_message(message,connection)
    handler = MessageHandler.get_handler(message)
    executor = MessageHandlerExecutor.new(handler,message,connection,self)
    executor.execute!
    @postmaster.add_messages(executor.outgoing_messages)
    @postmaster.deliver_messages!
  end

  def register_state_change_handlers!
    sign_out_handler = StateChangeHandlers::SignOutHandler.new(@postmaster)
    @connections.on(:remove_session) do |email|
      sign_out_handler.signed_out(email)
    end
  end

end

