class MessageHandlerExecutor
  def initialize(handler,message,domain_model)
    @handler = handler
    @message = message
    @domain_model = domain_model
    @context = {message: message, domain_model: domain_model}
    @authenticator = domain_model.authenticator
  end
  def execute!
    @outgoing_messages = @authenticator.protected_execution(@handler,@message,@domain_model)
  end
  def outgoing_messages
    Array(@outgoing_messages)
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
  def protected_execution(handler,message,domain_model)
    if authentication_sufficient?(handler,message)
      handler_instance = handler.new(message,domain_model)
      handler_instance.execute_and_return_response
    elsif not message.has_key? :auth_token
      AuthTokenRequiredMessage.new
    else
      AuthTokenInvalidMessage.new
    end
  end
end
