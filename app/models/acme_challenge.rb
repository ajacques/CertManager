class AcmeChallenge < ApplicationRecord
  belongs_to :certificate, autosave: true
  belongs_to :private_key
  belongs_to :sign_attempt, class_name: 'AcmeSignAttempt', foreign_key: 'acme_sign_attempt_id', inverse_of: :challenges
  after_create :after_create

  delegate :request_validation, to: :inner_challenge

  def full_path
    "http://#{domain_name}/.well-known/acme-challenge/#{token_key}"
  end

  def status
    ActiveSupport::StringInquirer.new last_status
  end

  def refresh_status
    challenge = inner_challenge
    self.last_status = challenge.status
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

  def self.from_authorization(attempt, auth)
    challenge = auth.http
    new(
      domain_name: auth.domain,
      token_key: challenge.token,
      token_value: challenge.file_content,
      verification_uri: challenge.url,
      expires_at: auth.expires,
      sign_attempt: attempt
    )
  end

  private

  def inner_challenge
    client = Settings::LetsEncrypt.new.build_client
    client.challenge url: verification_uri
  end

  def after_create
    @created_at = Time.now
  end

  delegate :acme_client, to: :sign_attempt
end
