module StateChangeHandlers
end
class StateChangeHandlers::SignOutHandler
  def initialize(postmaster)
    @postmaster = postmaster
  end
  def signed_out(emails)
    messages = Array(emails).map do |email|
      {type: 'user/status_changed',
       user_email: email,
       recipients_exclude: email,
       new_status: "offline"}
    end
    @postmaster.add_messages(messages)
    @postmaster.deliver_messages!
  end
end
