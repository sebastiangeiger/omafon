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
      try(&block)
      try_number = 0
      until @executed or try_number > 10
        sleep 0.05
        try(&block)
        try_number += 1
      end
      if try_number > 10
        raise "Could not connect to server after 10 tries"
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

    private
    def try(&block)
      EM.run do
        ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://0.0.0.0:8080')

        def ws.close_on_message=(new_value)
          @close_on_message = new_value
        end
        def ws.close_on_message?
          !!@close_on_message
        end

        ws.close_on_message = false

        def ws.close_on_message!
          self.close_on_message = true
        end

        ws.onopen do
          @was_connected = true
          @connected = true
        end

        ws.onmessage do |msg, type|
          @messages << msg
          if ws.close_on_message?
            ws.close
          end
        end

        ws.onclose do
          @closed = true
          @connected = false
          EM.stop
        end

        ws.onerror do |error|
          p "HELP"
          raise error
        end

        do_work = proc {
          if @connected and not @executed
            @executed = true
            block.call(ws)
          elsif not @executed
            EM.next_tick &do_work
          end
        }
        EM.next_tick &do_work
      end
    end

  end
end

