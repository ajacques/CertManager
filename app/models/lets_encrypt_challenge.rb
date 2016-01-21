class LetsEncryptChallenge < ActiveRecord::Base
  belongs_to :certificate
  belongs_to :private_key
  after_create :after_create

  def full_path
    "http://#{domain_name}:80/.well-known/acme-challenge/#{token_key}"
  end

  def request_verification(client)
    inner_challenge = Acme::Client::Resources::Challenges::HTTP01.new client, { 'uri' => verification_uri, 'token' => token_key }
    inner_challenge.request_verification
  end

  private
  def after_create
    @created_at = Time.now
  end
end
