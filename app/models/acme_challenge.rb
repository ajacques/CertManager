class AcmeChallenge < ApplicationRecord
  belongs_to :certificate, autosave: true
  belongs_to :private_key
  belongs_to :sign_attempt, class_name: 'AcmeSignAttempt', foreign_key: 'acme_sign_attempt_id'
  after_create :after_create

  delegate :request_verification, to: :inner_challenge

  def full_path
    "http://#{domain_name}/.well-known/acme-challenge/#{token_key}"
  end

  def status
    ActiveSupport::StringInquirer.new last_status
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
    challenge ||= cert.domain_names.map do |domain|
      for_domain(cert, settings, domain)
    end
    challenge
  end

  def self.for_domain(attempt, settings, domain)
    challenge = find_by(acme_sign_attempt_id: attempt.id, domain_name: domain)
    unless challenge
      authorization = acme_client(settings).authorize(domain: domain)
      challenge = authorization.http01
      challenge = new(
        domain_name: domain,
        token_key: challenge.token,
        token_value: challenge.file_content,
        verification_uri: challenge.uri,
        expires_at: authorization.expires,
        sign_attempt: attempt
      )
    end
    challenge
  end

  def self.acme_client(settings)
    Acme::Client.new(
      private_key: settings.private_key.to_openssl,
      endpoint: settings.endpoint
    )
  end

  private

  def inner_challenge
    inputs = { uri: verification_uri, token: token_key }
    Acme::Client::Resources::Challenges::HTTP01.new acme_client, inputs.stringify_keys
  end

  def after_create
    @created_at = Time.now
  end

  delegate :acme_client, to: :sign_attempt
end
