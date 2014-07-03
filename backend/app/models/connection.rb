require_relative '../helper/hash_object'
require_relative '../helper/observable'
require_relative '../my_logger'

class ConnectionCollection
  include Observable
  def initialize
    @connected_sessions = {}
  end
  def create_connection(domain_model)
    connection = Connection.new(domain_model)
    connection.on(:close) do
      email, connection = find_session(connection)
      @connected_sessions.delete(email)
      trigger(:remove_session, email)
    end
    connection
  end
  def register_session(options)
    email = options[:session].user_email
    connection = options[:connection]
    connection.identifier = email if connection.respond_to?(:identifier=)
    @connected_sessions[email] = connection
  end
  def find_session(desired_connection)
    @connected_sessions.select do |email,connection|
      connection == desired_connection
    end.first
  end
  def find_connection(recipient)
    if recipient.is_a? Connection
      recipient
    else
      @connected_sessions[recipient] || NoConnection.new(recipient)
    end
  end
end

class Connection
  #TODO: Connection should not know of domain_model, use Observable instead
  attr_writer :identifier
  include Observable
  def initialize(domain_model)
    @domain_model = domain_model
    @outgoing_messages = []
    @log = MyLogger.new
  end
  def incoming_message(message)
    @domain_model.incoming_message(message,self)
  end
  def empty_messages
    unless @outgoing_messages.empty?
      @log.debug("Emptying messages in #{identifier}")
      @outgoing_messages.clear
    end
  end
  def outgoing_messages(options = {})
    @outgoing_messages.select{|msg| HashObject.new(msg).fits_criteria?(options)}
  end
  def queue_message(message)
    @log.debug("Adding message: #{message} to #{identifier}")
    @outgoing_messages << message
  end
  def close
    @log.debug("Closing #{identifier}")
    trigger(:close)
  end
  def identifier
    if @identifier
      "<Connection for #{@identifier} (#{self.object_id})>"
    else
      self
    end
  end
end

class NoConnection
  def initialize(desired_recipient = nil)
    @log = MyLogger.new
    @desired_recipient = desired_recipient
  end
  def queue_message(message)
    @log.debug("Discarding #{message} to '#{desired_recipient}', connection does not exist")
  end
  private
  def desired_recipient
    @desired_recipient || "[unnamed recipient]"
  end
end
