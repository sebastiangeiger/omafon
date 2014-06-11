class ConnectionCollection
  def create_connection(domain_model)
    Connection.new(domain_model)
  end
end

class Connection
  def initialize(domain_model)
    @domain_model = domain_model
  end
  def incoming_message(message)
    @domain_model.incoming_message(message,self)
  end
end
