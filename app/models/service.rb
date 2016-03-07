class Service < ActiveRecord::Base
  belongs_to :certificate

  def properties
    super || (self.properties = {})
  end

  def deployable?
    certificate.signed?
  end

  def status
    status = node_status
    good = status.count(&:valid?)
    if status.count == 0
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
end
