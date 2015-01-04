require 'ostruct'

module CertManager
  module Configuration
    @config = nil
    public
    class << self
      def [](name)
        load unless @config
        @config[name]
      end

      def load
        yaml = YAML.load_file("#{Rails.root}/config/configuration.yml")
        @config = {}
        if yaml.is_a?(Hash)
          if yaml['default']
            @config.merge!(yaml['default'])
          end
          if yaml[Rails.env]
            @config.merge!(yaml[Rails.env])
          end
        end

        @config = OpenStruct.new(@config)

        if @config.email_delivery
          @config.email_delivery.each do |key, value|
            value.symbolize_keys! if value.respond_to?(:symbolize_keys)
            ActionMailer::Base.send("#{key}=", value)
          end
        end
      end

      def method_missing(method, *args, &block)
        load unless @config
        @config.send(method, *args)
      end
    end
  end
end