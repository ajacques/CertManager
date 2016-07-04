class AcmeSignAttempt < ActiveRecord::Base
  has_many :challenges, class_name: 'AcmeChallenge', autosave: true
  belongs_to :certificate
  belongs_to :private_key

  def status
    ActiveSupport::StringInquirer.new last_status
  end

  def fetch_signed
    signed = acme_client.new_certificate certificate.csr
    public_key = PublicKey.import signed.to_pem
    certificate.public_key = public_key
    public_key.private_key = certificate.private_key
    self.imported_key_id = public_key.id
    public_key
  end

  def self.for_certificate(certificate, settings)
    attempt = AcmeSignAttempt.find_by_certificate_id(certificate.id)
    unless attempt
      attempt = AcmeSignAttempt.new(
        acme_endpoint: settings.endpoint,
        certificate: certificate,
        private_key: certificate.private_key
      )
      certificate.csr.domain_names.each do |name|
        challenge = AcmeChallenge.for_domain(certificate, settings, name)
        attempt.challenges << challenge
      end
    end
    attempt
  end
end
