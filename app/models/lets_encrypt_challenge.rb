class LetsEncryptChallenge < ActiveRecord::Base
  belongs_to :certificate
  belongs_to :private_key

  def full_path
    "http://#{domain_name}:80/.well-known/acme-challenge/#{token_key}"
  end

  def request_verification(client)
    # TODO: Super hack here
    uri = URI(verification_uri)
    uri.port = 9512
    path = uri.to_s.sub(':9512', ':80')
    inner_challenge = Acme::Client::Resources::Challenges::HTTP01.new client, { 'uri' => path, 'token' => token_key }
    inner_challenge.request_verification
  end
end
