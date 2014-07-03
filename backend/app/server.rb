require_relative 'models/domain_model'
require 'em-websocket'
require 'json'
require_relative 'my_logger'


class Server
  def initialize(mode = :deployment)
    @mode = mode
    @domain_model = nil
    @log = MyLogger.new
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
    log = @log
    EM.run do
      log.debug("Started EventMachine")
      EM::WebSocket.run(:host => "0.0.0.0", :port => @port) do |ws|
        log.debug("Started WebSocket #{ws.object_id} on port #{@port}")
        open = false
        connection = nil
        ws.onopen { |handshake|
          open = true
          connection = @domain_model.create_connection
          log.info("Opened a connection in websocket #{connection.identifier}")
          ws.send(JSON.dump(type: :welcome))
        }
        ws.onclose {
          log.info "Closed connection in websocket #{connection.identifier}"
          connection.close
          open = false
        }
        ws.onmessage { |msg|
          log.info "Received on #{connection.object_id}: #{msg}"
          connection.incoming_message(JSON.parse(msg))
        }
        check_outgoing_messages = proc {
          if open
            connection.outgoing_messages.each do |msg|
              log.info "Sending out over #{connection.identifier}: #{msg} "
              ws.send(JSON.dump(msg))
            end
            connection.empty_messages
          end
          EM.next_tick &check_outgoing_messages
        }
        EM.next_tick &check_outgoing_messages
      end
    end
  end
end
