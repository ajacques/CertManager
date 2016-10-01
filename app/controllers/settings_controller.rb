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
    set.assign_attributes params.permit(settings_email_server: [:server, :port, :from_address, :enable_starttls])[:settings_email_server]
    set.save!

    if session.key? :app_redirect_to
      redirect_to session[:app_redirect_to]
      session.delete :app_redirect_to
    else
      redirect_to settings_path
    end
  end

  def validate_mail_server
    UserMailer.validate_mail_server(current_user).deliver_now
    respond_to do |format|
      format.all {
        render nothing: true, status: :accepted
      }
    end
  rescue Net::SMTPSyntaxError, Net::SMTPFatalError, OpenSSL::SSL::SSLError => e
    error = {
      status: :failed,
      message: e.message
    }
    respond_to do |format|
      format.json {
        render json: error, status: :bad_request
      }
    end
  end
end
