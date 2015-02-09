module CertManager
  public
  class InstrumentedRedis
    def initialize(options = {})
      ActiveSupport::Notifications.instrument "connect.redis", command: "CONNECT" do
        @client = Redis.new(options)
      end
    end
    def method_missing(command, *args, &block)
      ActiveSupport::Notifications.instrument "query.redis", command: command, query: args[0] do
        return @client.send(command, *args, &block)
      end
    end
  end
end