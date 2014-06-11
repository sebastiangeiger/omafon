require_relative '../my_logger'

class OutgoingMessage
  def initialize
    @content = {}
  end
  def fits_criteria?(options)
    options.reduce(true) { |all_attributes_fit, pair|
      key, value = pair
      attribute_fits = if options.respond_to? key
                         options.send(key) == value
                       elsif @content.has_key? key
                         @content[key] == value
                       else
                         false
                       end
      all_attributes_fit &= attribute_fits
    }
  end
  def sessions=(new_sessions)
    @sessions = new_sessions
    self
  end
  def to_hash
    @content
  end
end

class HandlerCreatedOutgoingMessage < OutgoingMessage
  def initialize(content)
    @content = content
  end
  def calculate_recipients!
    @content[:recipients] ||= []
    if exclude = @content.delete(:recipients_exclude)
      recipients = @sessions.user_emails - Array(exclude)
      @content[:recipients] += recipients
    end
    if single = @content.delete(:recipient)
      @content[:recipients] << single
    end
  end
  def to_hash
    calculate_recipients!
    @content
  end
end

class ErrorMessage < OutgoingMessage; end
class AuthTokenRequiredMessage < ErrorMessage
  def initialize
    @content = {type: "error/auth_token_required"}
  end
end

class AuthTokenInvalidMessage < ErrorMessage
  def to_hash
    {type: "error/auth_token_invalid"}
  end
end

class OutgoingMessageQueue
  def initialize
    @messages = []
    @log = MyLogger.new
  end
  def to_a
    @messages.map(&:to_hash)
  end
  def for_sessions(sessions)
    @messages.each do |message|
      message.sessions = sessions
    end
    self
  end
  def filter(options)
    @messages.select!{|msg| msg.fits_criteria?(options)}
    self
  end
  def add(new_messages)
    @log.debug "Added a message: #{new_messages}"
    @messages += new_messages
  end
  def clear
    @log.debug "Cleared the OutgoingMessageQueue" unless @messages.empty?
    @messages.clear
  end
end
