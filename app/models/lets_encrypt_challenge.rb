class LetsEncryptChallenge < ActiveRecord::Base
  belongs_to :certificate
  belongs_to :private_key
  after_create :after_create

  def full_path
    "http://#{domain_name}/.well-known/acme-challenge/#{token_key}"
  end

  def request_verification
    inner_challenge.request_verification
  end

  def status
    ActiveSupport::StringInquirer.new inner_challenge.verify_status
  end

  def self.for_certificate(cert, private_key)
    challenge = self.find_by_certificate_id(cert.id)
    unless challenge.any?
      domain = cert.domain_names.first
      authorization = acme_client.authorize(domain: domain)
      challenge = authorization.http01
      challenge = self.create!(
        certificate: cert,
        domain_name: domain,
        private_key: private_key,
        token_key: challenge.token,
        token_value: challenge.file_content,
        verification_uri: challenge.uri,
        #expires_at: authorization.expires
      )
    end
    challenge
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
    Acme::Client.new private_key: private_key.to_openssl, endpoint: 'http://acme-test.devvm'
  end
end
