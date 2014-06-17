class MessageHandlerExecutor
  def initialize(handler,message,current_connection,domain_model)
    @handler = handler
    @message = message
    @domain_model = domain_model
    @current_connection = current_connection
    @authenticator = domain_model.authenticator
  end
  def execute!
    filtered_message = @authenticator.filter_message(@handler,@message)
    if filtered_message[:type].start_with?("error/")
      result = filtered_message
    else
      handler_instance = @handler.new(filtered_message)
      inject_context(handler_instance)
      handler_instance.execute
      result = handler_instance.response
    end
    @outgoing_messages = result
  end
  def outgoing_messages
    if @outgoing_messages.is_a? Hash
      [@outgoing_messages]
    else
      @outgoing_messages
    end
  end
  private
  def inject_context(handler)
    [:users, :sessions, :connections].each do |key|
      variable_name = ('@'+key.to_s).to_sym
      handler.instance_variable_set(variable_name, @domain_model.send(key))
      handler.instance_eval("def #{key}; #{variable_name}; end")
    end
    handler.instance_variable_set(:@current_connection, @current_connection)
    def handler.current_connection
      @current_connection
    end
  end
end

class Authenticator
  def initialize(sessions)
    @sessions = sessions
  end
  def authentication_sufficient?(handler,message)
    handler.accessible_without_authentication? or
      (message.has_key? :auth_token and
       @sessions.find(auth_token: message[:auth_token]))
  end
  def filter_message(handler,message)
    if authentication_sufficient?(handler,message)
      message.reject{|k| k == :auth_token}
    elsif not message.has_key? :auth_token
      {type: "error/auth_token_required"}
    else
      {type: "error/auth_token_invalid"}
    end
  end
end
