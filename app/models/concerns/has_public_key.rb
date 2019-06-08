module HasPublicKey
  extend ActiveSupport::Concern
  def crl_endpoints
    public_key
      .try(:crl_distribution_points)
      .try(:uris)
  end

  def ocsp_endpoints
    public_key
      .try(:authority_info_access)
      .try(:ocsp)
      .try(:names)
      .try(:map, proc { |obj| obj.value })
  end

  def expires_in
    return 9_999_999.years unless expires?

    public_key.not_after - Time.now
  end

  def expires?
    public_key.present?
  end

  def expired?
    expires? && public_key.not_after < Time.now
  end

  def stub?
    public_key.nil? && private_key.nil?
  end

  def signed?
    public_key.present?
  end

  def can_sign?
    public_key&.is_ca
  end

  def ocsp_enabled?
    ocsp_endpoints.present?
  end

  def crl_enabled?
    crl_endpoints.present?
  end

  def subject_alternate_names
    public_key.try(:subject_alternate_names) || []
  end
end
