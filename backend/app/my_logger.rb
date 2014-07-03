require 'logger'
class MyLogger < Logger
  def self.log_to=(destination)
    @@destination = destination
  end
  def initialize
    if defined? @@destination
      super(@@destination)
    else
      super("log/test.log")
    end
  end
end
