require 'em-websocket'
require 'json'

class Server
  def initialize(mode = :deployment)
    @mode = mode
  end
  def domain_model=(new_model)
    @domain_model = new_model
  end

  def run
    EM.run do
      EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
        open = false
        ws.onopen { |handshake|
          open = true
          ws.send(JSON.dump(type: :welcome))
        }
        ws.onclose {
          open = false
        }
        ws.onmessage { |msg|
          @domain_model.incoming_message(JSON.parse(msg))
        }
        check_outgoing_messages = proc {
          if open
            @domain_model.outgoing_messages.each do |msg|
              ws.send(JSON.dump(msg))
            end
            @domain_model.empty_messages
          end
          EM.next_tick &check_outgoing_messages
        }
        EM.next_tick &check_outgoing_messages
      end
    end
  end
end
