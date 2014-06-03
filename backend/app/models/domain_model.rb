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
    @outgoing_messages += handler.new(message,self).execute
  end
  def empty_messages
    @outgoing_messages.clear
  end
end

