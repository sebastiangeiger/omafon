require_relative '../helper/hash_object'

class ConnectionCollection
  def initialize
    @connected_sessions = {}
  end
  def create_connection(domain_model)
    Connection.new(domain_model)
  end
  def register_session(options)
    email = options[:session].user_email
    @connected_sessions[email] = options[:connection]
  end
  def find_connection(recipient)
    if recipient.is_a? Connection
      recipient
    else
      @connected_sessions[recipient]
    end
  end
end

class Connection
  def initialize(domain_model)
    @domain_model = domain_model
    @outgoing_messages = []
  end
  def incoming_message(message)
    @domain_model.incoming_message(message,self)
  end
  def empty_messages
    @outgoing_messages.clear
  end
  def outgoing_messages(options = {})
    @outgoing_messages.select{|msg| HashObject.new(msg).fits_criteria?(options)}
  end
  def queue_message(message)
    @outgoing_messages << message
  end
end
