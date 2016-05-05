class Settings::AgentConfig < Settings::Group
  config_keys :private_key_id

  def private_key
    PrivateKey.find(private_key_id) if private_key_id
  end
end
