require_relative '../my_logger'

class OutgoingMessageQueue
  def initialize(sessions)
    @messages = []
    @log = MyLogger.new
    @sessions = sessions
  end
  def to_a
    @messages
  end
  def add(new_messages)
    @log.debug "Added messages: #{new_messages}"
    new_messages.each do |message|
      distribute(correct_recipients(message.to_hash))
    end
  end
  def clear
    @log.debug "Cleared the OutgoingMessageQueue" unless @messages.empty?
    @messages.clear
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
  def distribute(message)
    @messages << message
  end
end
