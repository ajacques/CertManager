module CertManager
  public
  class InstrumentedRedis
    def initialize(options = {})
      ActiveSupport::Notifications.instrument "connect.redis", command: "CONNECT" do
        @client = Redis.new(options)
      end
    end
    def method_missing(command, *args, &block)
      ActiveSupport::Notifications.instrument "query.redis", command: command, args: args do
        return @client.send(command, *args, &block)
      end
    end
  end
end