require 'em-websocket'

class Server
  def initialize(mode = :deployment)
    @mode = mode
  end

  def run
    EM.run do
      EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
        ws.onopen { |handshake|
          ws.send "Hello Client, you connected to #{handshake.path}"
        }
        ws.onmessage { |msg|
          p msg
        }
      end
    end
  end
end
