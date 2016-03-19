class SettingsController < ApplicationController
  def show
    @signing_keys = PrivateKey.with_subjects.map { |key|
      [key.CN, key.id]
    }
  end

  def update
    set = Settings::LetsEncrypt.new
    set.assign_attributes params.permit(settings_lets_encrypt: [:endpoint, :private_key_id])[:settings_lets_encrypt]
    set.save!

    set = Settings::EmailServer.new
    set.assign_attributes params.permit(settings_email_server: [:server, :port])[:settings_email_server]
    set.save!

    redirect_to settings_path
  end

  def validate_mail_server
    UserMailer.validate_mail_server(current_user).deliver_now
    render nothing: true
  end
end
