require_relative 'models/domain_model'
require 'em-websocket'
require 'json'

class Server
  def initialize(mode = :deployment)
    @mode = mode
    @domain_model = nil
  end
  def start(domain_model,options = {})
    @port = options[:port] || 8080
    @run_in_background = !options[:foreground]
    @domain_model = domain_model
    if @run_in_background
      @pid = Process.fork { self.send(:run) }
    else
      puts "Server starting in foreground on port #{@port}..."
      run
    end
  end
  def kill
    if @pid
      Process.kill("TERM",@pid)
    elsif @pid.nil?
      raise "PID not set"
    end
  end

  private
  def run
    EM.run do
      EM::WebSocket.run(:host => "0.0.0.0", :port => @port) do |ws|
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
