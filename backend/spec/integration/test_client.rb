require 'logger'
module OmaFon
  class TestClient
    TIMEOUT = 1 #seconds
    def initialize(options = {})
      @messages = []
      @was_connected = false
      @connected = false
      @closed = false
      @executed = false
      name = options[:name] || "TestClient"
      @log = TestClient::Logger.new(!!options[:verbose],name)
    end

    def run(&block)
      @log.debug("Running")
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
      @messages
    end

    def messages_of_type(type)
      if type.is_a? Regexp
        messages.select{|msg| msg["type"] =~ type}
      elsif type.is_a? String
        messages.select{|msg| msg["type"] == type}
      else
        raise "Expected String or Regexp"
      end
    end

    private
    def name
      @name
    end

    def try(&block)
      EM.run do
        ws = WebSocket::EventMachine::Client.connect(:uri => 'ws://0.0.0.0:8080')

        def ws.close_if(&block)
          @close_if_block = block
        end
        def ws.close_if_block
          @close_if_block
        end
        def ws.check_for_close(messages,log)
          types = messages.map{|msg| msg["type"]}
          if close_if_block and close_if_block.call(messages,types)
            log.debug("Close block said I am done (#{messages})")
            close
          end
        end

        ws.onopen do
          @log.debug("Opened connection")
          @was_connected = true
          @connected = true
        end

        ws.onmessage do |msg, type|
          @log.debug("Received #{msg}")
          @messages << JSON.parse(msg)
          ws.check_for_close(@messages,@log)
        end

        ws.onclose do
          @closed = true
          @connected = false
          @log.debug("TestClient received onclose event")
          EM.stop
        end

        ws.onerror do |error|
          p "HELP"
          raise error
        end

        do_work = proc {
          if @connected and not @executed
            @log.debug("Executing work block")
            @executed = true
            block.call(ws,@log)
            @log.debug("Done executing block")
          elsif not @executed
            EM.next_tick &do_work
          end
        }
        EM.next_tick &do_work

        check_for_close = proc {
          ws.check_for_close(@messages,@log)
          EM.next_tick &check_for_close
        }
        EM.next_tick &check_for_close
      end
    end

    class Logger
      attr_reader :name
      def initialize(verbose,name)
        @log = ::Logger.new(STDOUT)
        @name = name
        if verbose
          @log.level = ::Logger::DEBUG
        else
          @log.level = ::Logger::FATAL
        end
        debug("Logger online")
      end
      def debug(msg)
        @log.debug(format(msg))
      end
      def fatal(msg)
        @log.fatal(format(msg))
      end
      def thread_id
        Thread.current.object_id.to_s[-4..-1]
      end
      def format(msg)
        "[#{name}] [@#{thread_id}] #{msg}"
      end
    end
  end
end

