class Settings::EmailServer < Settings::Group
  config_keys :server, :port, :from_address

  def delivery_method
    'smtp'
  end

  def action_mailer_settings
    {
      address: server,
      domain: '',
      port: port
    }
  end
end
