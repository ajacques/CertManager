require 'ostruct'

module CertManager
  module SecurityPolicy
    @config = nil
    public
    class << self
      def load
        @config = OpenStruct.new(YAML.load_file("#{Rails.root}/config/security_policy.yml"))
      end

      def method_missing(method, *args, &block)
        load# unless @config
        set = @config.send(method, *args)
        if set['type'] == 'array'
          ArrayPolicyChecker.new(set)
        elsif set['type'] == 'integer'
          IntegerPolicyChecker.new(set)
        end
      end
    end
    private
    class ArrayPolicyChecker
      def initialize(policy_set)
        @set = policy_set
      end
      def secure?(method)
        @set['secure'].include?(method)
      end
      def insecure?(method)
        not secure? method
      end
    end
    class IntegerPolicyChecker
      def initialize(policy_set)
        @set = policy_set
      end
      def secure?(method)
        method <= @set['min_secure'].to_i - 1
      end
      def insecure?(method)
        not secure? method
      end
    end
  end
end