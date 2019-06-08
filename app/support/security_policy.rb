module SecurityPolicy
  @config = nil
  class << self
    def load_file
      return if @config && !Rails.env.development?

      @config = YAML.load_file(Rails.root.join('config', 'security_policy.yml'))
    end

    def respond_to_missing?(method, include_private = false)
      load_file
      return true if @config.key? method

      super
    end

    def method_missing(method, *_args, &_block)
      load_file
      set = @config.send(:[], method.to_s)
      raise "No policy for '#{method}'" if set.blank?

      if set['type'] == 'array'
        ArrayPolicyChecker.new(set)
      elsif set['type'] == 'integer'
        IntegerPolicyChecker.new(set)
      end
    end
  end

  class PolicyChecker
    def initialize(policy_set)
      @set = policy_set
    end

    def default
      @set['default']
    end

    def secure
      @set['secure']
    end

    def insecure?(method)
      !secure? method
    end
  end
  class ArrayPolicyChecker < PolicyChecker
    def secure?(value)
      @set['secure'].include? value
    end
  end
  class IntegerPolicyChecker < PolicyChecker
    def secure?(method)
      method >= @set['min_secure'].to_i
    end
  end
end
