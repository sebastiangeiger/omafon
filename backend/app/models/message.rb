class OutgoingMessage
  def initialize(content)
    @content = content
  end
  def sessions=(new_sessions)
    @sessions = new_sessions
    self
  end
  def calculate_recipients!
    if exclude = @content.delete(:recipients_exclude)
      recipients = @sessions.user_emails - Array(exclude)
      @content[:recipients] ||= []
      @content[:recipients] += recipients
    end
  end
  def to_hash
    calculate_recipients!
    @content
  end
end

class OutgoingMessageQueue
  def initialize
    @messages = []
  end
  def to_a
    @messages.map(&:to_hash)
  end
  def for_sessions(sessions)
    @messages.each do |message|
      if message.respond_to? :sessions=
        message.sessions = sessions
      end
    end
    self
  end
  def add(new_messages)
    @messages += new_messages
  end
  def clear
    @messages.clear
  end
end
