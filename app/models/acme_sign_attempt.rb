class AcmeSignAttempt < ActiveRecord::Base
  has_many :challenges, class_name: 'AcmeChallenge', autosave: true
  belongs_to :certificate, autosave: true
  belongs_to :private_key
  belongs_to :imported_key, class_name: 'PublicKey', autosave: true

  def status
    ActiveSupport::StringInquirer.new last_status
  end

  def status_complete?
    !(status.unchecked? || status.working?)
  end

  delegate :errored?, to: :status

  def problem?
    status.failed? || status.errored?
  end

  def acme_client
    Acme::Client.new private_key: private_key.to_openssl, endpoint: acme_endpoint
  end

  def fetch_signed
    signed = acme_client.new_certificate certificate.csr
    set = ImportSet.from_array signed.x509_fullchain
    set.import

    self.imported_key = set.public_keys.first

    imported_key
  end

  def self.create_for_certificate(certificate, settings)
    attempt = certificate.inflight_acme_sign_attempt
    unless attempt
      attempt = AcmeSignAttempt.new(
        acme_endpoint: settings.endpoint,
        certificate: certificate,
        private_key: settings.private_key
      )
      certificate.inflight_acme_sign_attempt = attempt
      certificate.to_csr.domain_names.each do |name|
        challenge = AcmeChallenge.for_domain(attempt, settings, name)
        attempt.challenges << challenge
      end
    end
    attempt
  end
end
