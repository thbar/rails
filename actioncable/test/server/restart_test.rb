require "test_helper"
require "stubs/test_server"

class RestartTest < ActiveSupport::TestCase
  setup do
    @original_config = ActionCable::Server::Base.config
    ActionCable::Server::Base.config = @original_config.dup
  end

  teardown do
    ActionCable::Server::Base.config = @original_config
  end

  test "replaces the worker" do
    server = ActionCable::Server::Base.new
    server.config.worker_pool_size = 2

    conn = ActionCable::Connection::Base.new(server, {})

    never_run = Concurrent::Event.new
    server.worker_pool.async_exec(self, connection: conn) { sleep 10 }
    server.worker_pool.async_exec(self, connection: conn) { sleep 10 }
    server.worker_pool.async_exec(self, connection: conn) { never_run.set }
    old_pool = server.worker_pool

    server.restart

    should_run = Concurrent::Event.new
    server.worker_pool.async_exec(self, connection: conn) { should_run.set }
    new_pool = server.worker_pool

    assert old_pool.stopping?, "old pool should be stopping"
    assert !new_pool.stopping?, "new pool should be running"

    never_run.wait(1)
    should_run.wait(1)

    assert !never_run.set?, "old pool should be busy with sleeps"
    assert should_run.set?, "new pool should be working"
  end

  class DummyAdapter
    def initialize(server)
      @stopped = false
    end

    def shutdown
      @stopped = true
    end

    def stopped?
      @stopped
    end
  end

  test "replaces the subscription adapter" do
    server = ActionCable::Server::Base.new
    class << server.config
      def pubsub_adapter
        DummyAdapter
      end
    end

    old_adapter = server.pubsub
    server.restart

    new_adapter = server.pubsub

    assert_not_equal new_adapter, old_adapter
    assert !new_adapter.stopped?
    assert old_adapter.stopped?
  end
end
