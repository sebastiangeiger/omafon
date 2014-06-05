class MessageHandler::User::SignIn < MessageHandler::AbstractHandler
  def self.accessible_without_authentication?
    true
  end
  def execute
    user = users.authenticate(email: message[:email],
                              password: message[:password])
    if user
      session = sessions.create_session(user: user)
      respond({type: 'user/sign_in_successful',
               auth_token: session.auth_token})
      respond({type: 'user/status_changed',
               user_email: user.email,
               recipients_exclude: user.email,
               new_status: "online"})
    else
      respond({type: 'user/sign_in_failed'})
    end
  end
end
