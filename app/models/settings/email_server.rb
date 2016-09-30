class Settings::EmailServer < Settings::Group
  config_keys :server, :port, :from_address, :enable_starttls

  def delivery_method
    'smtp'
  end

  def action_mailer_settings
    {
      address: server,
      port: port,
      enable_starttls_auto: enable_starttls
    }
  end
end
