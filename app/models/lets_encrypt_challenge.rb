class LetsEncryptChallenge < ActiveRecord::Base
  belongs_to :certificate
  belongs_to :private_key
  after_create :after_create

  delegate :request_verification, to: :inner_challenge

  def full_path
    "http://#{domain_name}/.well-known/acme-challenge/#{token_key}"
  end

  def status
    ActiveSupport::StringInquirer.new inner_challenge.verify_status
  end

  def self.for_certificate(cert, private_key)
    challenge = find_by_certificate_id(cert.id)
    unless challenge
      domain = cert.domain_names.first
      authorization = acme_client(private_key).authorize(domain: domain)
      challenge = authorization.http01
      challenge = create!(
        certificate: cert,
        domain_name: domain,
        private_key: private_key,
        token_key: challenge.token,
        token_value: challenge.file_content,
        verification_uri: challenge.uri
      )
    end
    challenge
  end

  def self.acme_client(private_key)
    Acme::Client.new private_key: private_key.to_openssl, endpoint: 'http://acme-test.devvm'
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
    LetsEncryptChallenge.acme_client(private_key)
  end
end
