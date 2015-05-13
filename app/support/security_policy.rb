module SecurityPolicy
  @config = nil
  public
  class << self
    def load_file
      @config = YAML.load_file("#{Rails.root}/config/security_policy.yml")
    end

    def method_missing(method, *args, &block)
      load_file unless @config and not Rails.env.development?
      set = @config.send(:[], method.to_s)
      raise "No policy for '#{method}'" unless set.present?
      if set['type'] == 'array'
        ArrayPolicyChecker.new(set)
      elsif set['type'] == 'integer'
        IntegerPolicyChecker.new(set)
      end
    end
  end
  private
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
      not secure? method
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