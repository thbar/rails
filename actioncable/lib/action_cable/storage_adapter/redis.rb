require 'em-hiredis'
require 'redis'

module ActionCable
  module StorageAdapter
    class Redis < Base
      def broadcast(channel, payload)
        _broadcast.publish(channel, payload)
      end

      def subscribe(channel, message_callback, success_callback = nil)
        redis.pubsub.subscribe(channel, &message_callback).tap do |result|
          result.callback(&success_callback) if success_callback
        end
      end

      def unsubscribe(channel, message_callback)
        redis.pubsub.unsubscribe_proc(channel, message_callback)
      end

      private

      # The redis instance used for broadcasting. Not intended for direct user use.
      def _broadcast
        @broadcast ||= ::Redis.new(@server.config.config_opts)
      end

      # The EventMachine Redis instance used by the pubsub adapter.
      def redis
        @redis ||= EM::Hiredis.connect(@server.config.config_opts[:url]).tap do |redis|
          redis.on(:reconnect_failed) do
            @logger.info "[ActionCable] Redis reconnect failed."
            # logger.info "[ActionCable] Redis reconnected. Closing all the open connections."
            # @connections.map &:close
          end
        end
      end
    end
  end
end
