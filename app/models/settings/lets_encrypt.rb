class Settings::LetsEncrypt < Settings::Group
  config_keys :private_key_id, :endpoint, :accepted_terms, :registration_uri

  def private_key?
    private_key_id.present?
  end

  alias accepted_terms? accepted_terms

  def private_key
    PrivateKey.find(private_key_id)
  end

  def build_client
    Acme::Client.new private_key: private_key.to_openssl, directory: endpoint, kid: registration_uri
  end
end
