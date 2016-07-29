class Service < ActiveRecord::Base
  belongs_to :certificate

  def properties
    # This can't be the simplest way to do this
    s = super
    return s if s
    self.properties = {}
    super
  end

  def deployable?
    certificate.signed?
  end

  def node_status
    rkey = "SERVICE_#{id}_NODESTATUS"
    redis = CertManager::Configuration.redis_client
    redis.hgetall(rkey).map { |key, value|
      json = JSON.parse value
      node = Node.new key
      node.hash = json['hash']
      node.valid = json['valid']
      node.exists = json['exists']
      node.updated_at = Time.parse(json['update'])
      node
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
      define_method(property) do
        self.properties[prop]
      end
      define_method("#{property}=") do |value|
        self.properties[prop] = value
      end
    end
  end
end
