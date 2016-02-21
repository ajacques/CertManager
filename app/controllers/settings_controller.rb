class SettingsController < ApplicationController
  def show
    @signing_keys = PrivateKey.with_subjects.map { |key|
      [key.CN, key.id]
    }
  end

  def update
    set = Settings::LetsEncrypt.new
    set.assign_attributes params.permit(settings_lets_encrypt: [:endpoint, :private_key])[:settings_lets_encrypt]
    set.save!

    set = Settings::EmailServer.new
    set.assign_attributes params.permit(settings_email_server: [:server, :port])[:settings_email_server]
    ActionMailer::Base.smtp_settings['address'] = set.server if set.server_changed?
    ActionMailer::Base.smtp_settings['port'] = set.port if set.port_changed?
    set.save!

    redirect_to settings_path
  end
end
