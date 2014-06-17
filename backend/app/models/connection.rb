require_relative '../helper/hash_object'

class ConnectionCollection
  def create_connection(domain_model)
    Connection.new(domain_model)
  end
  def register_session(options)
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
end
