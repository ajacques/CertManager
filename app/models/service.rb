class Service < ApplicationRecord
  belongs_to :certificate

  class << self
    def service_props
      @service_props ||= Set.new
    end
  end

  def properties
    # This can't be the simplest way to do this
    s = super
    return s if s

    self.properties = {}
    super
  end

  def push_deployable?
    false
  end

  def deployable?
    certificate.signed?
  end

  def node_status
    rkey = "SERVICE_#{id}_NODESTATUS"
    redis = CertManager::Configuration.redis_client
    redis.hgetall(rkey).map { |_key, value|
      Node.new JSON.parse value
    }
  end

  def status
    status = node_status
    good = status.count(&:valid?)
    if status.count.zero?
      'Unknown'
    elsif good == status.count
      "Running [#{good}/#{status.count}]"
    else
      'Inconsistent'
    end
  end

  def model_name
    ActiveModel::Name.new(Service)
  end

  def self.service_prop(*properties)
    properties.each do |property|
      prop = property.to_s
      service_props << property
      define_method(property) do
        self.properties[prop]
      end
      define_method("#{property}=") do |value|
        self.properties[prop] = value
      end
    end
  end
end
