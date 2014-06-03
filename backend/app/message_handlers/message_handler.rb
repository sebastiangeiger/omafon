module MessageHandler
  def self.get_handler(message)
    if message and message[:type]
      module_name = self.message_type_to_module_name(message[:type])
      begin
        module_name.reduce(Module, :const_get)
      rescue NameError => e
        raise "Handler #{module_name.join('::')} not defined"
      end
    else
      raise 'Type of message is missing'
    end
  end

  private
  def self.message_type_to_module_name(type)
    camelized_type = type.split('/').map{|mod| mod.camelize}
    ['MessageHandler'] + camelized_type
  end
end

class MessageHandler::AbstractHandler
  def initialize(message,domain_model)
    @message = message
    @domain_model = domain_model
  end
  private
  def respond(answer)
    [answer]
  end
  def message; @message; end
  def users; @domain_model.users; end
end

module MessageHandler::User; end
require_relative 'user/sign_in'
