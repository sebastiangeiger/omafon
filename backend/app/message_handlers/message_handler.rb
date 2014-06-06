module MessageHandler
  def self.get_handler(message)
    if message and message[:type]
      class_name = self.message_type_to_class_name(message[:type])
      begin
        class_name.reduce(Module, :const_get)
      rescue NameError => e
        raise "Handler #{class_name.join('::')} not defined"
      end
    else
      raise 'Type of message is missing'
    end
  end

  private
  def self.message_type_to_class_name(type)
    camelized_type = type.split('/').map{|mod| mod.camelize}
    ['MessageHandler'] + camelized_type
  end
end

class MessageHandler::AbstractHandler
  def initialize(message,domain_model)
    @message = message
    @domain_model = domain_model
    @response = []
  end
  def self.accessible_without_authentication?
    false
  end
  def execute_and_return_response
    execute
    @response
  end
  private
  def respond(*answers)
    @response += answers.map{|answer| HandlerCreatedOutgoingMessage.new(answer)}
  end
  def message; @message; end
  def users; @domain_model.users; end
  def sessions; @domain_model.sessions; end
end

module MessageHandler::User; end
require_relative 'user/sign_in'
