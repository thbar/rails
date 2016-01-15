module ActionCable
  module StorageAdapter
    class Base
      attr_reader :logger, :server

      def initialize(server)
        @server = server
        @logger = @server.logger
      end

      def broadcast(channel, payload)
        raise NotImplementedError
      end

      def subscribe(channel, callback, success_callback = nil)
        raise NotImplementedError
      end

      def unsubscribe(channel, callback, success_callback = nil)
        raise NotImplementedError
      end
    end
  end
end
