module OmaFon
  class TestClient
    attr_reader :messages
    def initialize
      @messages = []
      @was_connected = false
      @connected = false
      @closed = false
    end

    def run(&block)
      EM.run do

        ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://0.0.0.0:8080')

        ws.onopen do
          @was_connected = true
          @connected = true
        end

        ws.onmessage do |msg, type|
          @messages << msg
        end

        ws.onclose do
          @closed = true
          @connected = false
          EM.stop
        end

        do_work = proc {
          if @connected
            block.call(ws)
          else
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
  end
end

