class MessageHandler::User::SignIn
  def initialize(message,domain_model)
    @message = message
    @domain_model = domain_model
  end
  def execute
    user = users.authenticate(email: message[:email],
                              password: message[:password])
    if user
      [{type: 'user/sign_in_successful',
        auth_token: SecureRandom.hex(10)}]
    else
      [{type: 'user/sign_in_failed'}]
    end
  end
  private
  def message; @message; end
  def users; @domain_model.users; end
end
