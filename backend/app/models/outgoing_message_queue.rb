require_relative '../my_logger'

class OutgoingMessageQueue
  def initialize(sessions)
    @messages = []
    @log = MyLogger.new
    @sessions = sessions
  end
  def to_a
    correct_recipients(@messages.map(&:to_hash))
  end
  def filter(options)
    @messages.select!{|msg| HashObject.new(msg).fits_criteria?(options)}
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
  def correct_recipients(message_hashes)
    message_hashes.each do |message|
      if recipient = message.delete(:recipient)
        message[:recipients] = [recipient]
      end
      if excluded = message.delete(:recipients_exclude)
        message[:recipients] = @sessions.user_emails - Array(excluded)
      end
    end
  end
end

class HashObject
  def initialize(content)
    @content = content
  end
  def method_missing(method,*args,&block)
    if @content.has_key? method
      @content[method]
    else
      super(method,args,block)
    end
  end
  def fits_criteria?(options)
    options.inject(true) do |all_attributes_fit, desired_attribute|
      desired_key, desired_value = desired_attribute
      if @content.has_key? desired_key
        this_on_fits = (@content[desired_key] == desired_value)
      else
        this_on_fits = false
      end
      all_attributes_fit &&= this_on_fits
    end
  end
end
