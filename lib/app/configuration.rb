module CertManager
  # Exposes configuration values for the the system
  module Configuration
    @config = nil

    class << self
      def load_file
        yaml = YAML.load_file("#{Rails.root}/config/configuration.yml")

        @config = HashWithIndifferentAccess.new(yaml)
      end

      def redis_client
        CertManager::InstrumentedRedis.new redis
      end

      def redis_client_no_metrics
        Redis.new redis
      end

      def method_missing(method, *_args, &_block)
        load_file unless @config && Rails.env.production?
        @config[method]
      end
    end
  end
end
