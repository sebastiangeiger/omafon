class MessageHandler::User::SignIn < MessageHandler::AbstractHandler
  def self.accessible_without_authentication?
    true
  end
  def execute
    user = users.authenticate(email: message[:email],
                              password: message[:password])
    if user
      respond({type: 'user/sign_in_successful',
               auth_token: SecureRandom.hex(10)})
    else
      respond({type: 'user/sign_in_failed'})
    end
  end
end
