module HasPublicKey
  extend ActiveSupport::Concern
  def crl_endpoints
    self.public_key
      .try(:crl_distribution_points)
      .try(:uris)
  end
  def ocsp_endpoints
    self.public_key
      .try(:authority_info_access)
      .try(:ocsp)
      .try(:names)
      .try(:map, Proc.new {|obj|
        obj.value
      })
  end
  def expires_in
    return 9999999.years if not expires?
    self.public_key.not_after - Time.now
  end
  def expires?
    public_key.present?
  end
  def expired?
    expires? and self.public_key.not_after < Time.now
  end
  def stub?
    public_key.nil? and private_key.nil?
  end
  def signed?
    public_key.present?
  end
  def can_sign?
    public_key.basic_constraints
      .try(:is_ca?)
  end
  def ocsp_enabled?
    ocsp_endpoints.present?
  end
  def crl_enabled?
    crl_endpoints.present?
  end
end