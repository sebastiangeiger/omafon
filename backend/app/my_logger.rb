require 'logger'
class MyLogger < Logger
  def initialize
    super("log/test.log")
  end
end
