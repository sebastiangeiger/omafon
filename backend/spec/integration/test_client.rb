module OmaFon
  class TestClient
    def initialize
      @messages = []
      @was_connected = false
      @connected = false
      @closed = false
      @executed = false
    end

    def run(&block)
      EM.run do
        p "Running EventMachine"

        ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://0.0.0.0:8080')

        def ws.close_on_message=(new_value)
          @close_on_message = new_value
        end
        def ws.close_on_message?
          !!@close_on_message
        end

        ws.close_on_message = false

        ws.instance_variable_set(:@start_time, Time.new)
        def ws.check_timeout!
          diff = Time.new - @start_time
          p diff
          if diff > 1
            self.close
            raise "Timed out"
          end
        end

        def ws.start_timeout!
          stop_it = proc {
            check_timeout!
            EM.next_tick &stop_it
          }
          EM.next_tick &stop_it
        end

        def ws.close_on_message!
          self.close_on_message = true
        end

        ws.onopen do
          p "Connected"
          @was_connected = true
          @connected = true
          start_time = Time.new
        end

        ws.onmessage do |msg, type|
          @messages << msg
          if ws.close_on_message?
            p "Closing on message"
            ws.close
          end
        end

        ws.onclose do
          p "closing on close"
          @closed = true
          @connected = false
          EM.stop
        end

        do_work = proc {
          ws.check_timeout!
          if @connected and not @executed
            @executed = true
            block.call(ws)
            ws.start_timeout!
          else
            p "Not connected yet"
            EM.next_tick &do_work
          end
        }
        EM.next_tick &do_work
      end
    end

    def connected?
      @connected
    end

    def was_connected?
      @was_connected
    end

    def closed?
      @closed
    end

    def messages
      @messages.map{|msg| JSON.parse(msg)}
    end

    def messages_of_type(type)
      messages.select{|msg| msg["type"] == type}
    end
  end
end

