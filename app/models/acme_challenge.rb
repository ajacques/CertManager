class AcmeChallenge < ActiveRecord::Base
  belongs_to :certificate, autosave: true
  belongs_to :private_key
  after_create :after_create

  delegate :request_verification, to: :inner_challenge

  def full_path
    "http://#{domain_name}/.well-known/acme-challenge/#{token_key}"
  end

  def status
    ActiveSupport::StringInquirer.new last_status
  end

  def fetch_signed
    signed = acme_client.new_certificate certificate.csr
    public_key = PublicKey.import signed.to_pem
    certificate.public_key = public_key
    public_key.private_key = certificate.private_key
    public_key
  end

  def refresh_status
    challenge = inner_challenge
    self.last_status = challenge.verify_status
    self.error_message = challenge.error
  end

  def expired?
    expires_at < Time.now
  end

  def valid_challenge?
    !status.invalid?
  end

  def self.for_certificate(cert, settings)
    challenge = where(certificate_id: cert.id)
    unless challenge
      challenge = cert.domain_names.map do |domain|
        for_domain(cert, settings, domain)
      end
    end
    challenge
  end

  def self.for_domain(cert, settings, domain)
    challenge = find_by(certificate_id: cert.id, domain_name: domain)
    unless challenge
      authorization = acme_client(settings).authorize(domain: domain)
      challenge = authorization.http01
      challenge = create!(
        certificate: cert,
        domain_name: domain,
        private_key: settings.private_key,
        token_key: challenge.token,
        token_value: challenge.file_content,
        verification_uri: challenge.uri,
        expires_at: authorization.expires,
        acme_endpoint: settings.endpoint
      )
    end
    challenge
  end

  def self.acme_client(settings)
    Acme::Client.new private_key: settings.private_key.to_openssl, endpoint: settings.endpoint
  end

  private

  def inner_challenge
    inputs = { uri: verification_uri, token: token_key }
    Acme::Client::Resources::Challenges::HTTP01.new acme_client, inputs.stringify_keys
  end

  def after_create
    @created_at = Time.now
  end

  def acme_client
    Acme::Client.new private_key: private_key, endpoint: acme_endpoint
  end
end
