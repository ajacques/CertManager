module CertManager
  # Exposes configuration values for the the system
  module Configuration
    @config = nil

    class << self
      def load_file
        return if @config && Rails.env.production?

        yaml = YAML.load_file(Rails.root.join('config', 'configuration.yml'))

        @config = HashWithIndifferentAccess.new(yaml)
      end

      def redis_client
        CertManager::InstrumentedRedis.new redis
      end

      def redis_client_no_metrics
        Redis.new redis
      end

      def respond_to_missing?(method)
        load_file
        @config.key? method
      end

      def method_missing(method, *_args, &_block)
        load_file
        @config[method]
      end
    end
  end
end
