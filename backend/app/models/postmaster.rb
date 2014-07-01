require_relative '../my_logger'

class Postmaster
  def initialize(sessions,connections)
    @messages = []
    @log = MyLogger.new
    @sessions = sessions
    @connections = connections
  end

  def add_messages(new_messages)
    new_messages.map! do |message|
      correct_recipients(message.to_hash)
    end
    @log.debug "Added #{new_messages.count} messages"
    @messages += new_messages
  end

  def correct_recipients(message)
    if recipient = message.delete(:recipient)
      message[:recipients] = [recipient]
    end
    if excluded = message.delete(:recipients_exclude)
      message[:recipients] = @sessions.user_emails - Array(excluded)
    end
    message
  end

  def deliver_messages!
    unless @messages.empty?
      @messages.each {|msg| deliver_message(msg)}
      @messages.clear
    end
  end

  def deliver_message(message)
    recipients = message.delete(:recipients) || []
    recipients.each do |recipient|
      @connections.find_connection(recipient).queue_message(message)
    end
  end
end
