class LetsEncryptController < ApplicationController
  attr_reader :acme_settings
  append_before_action :load_settings
  skip_before_action :require_login, only: [:validate_token]

  # Specification: https://letsencrypt.github.io/acme-spec/
  def index
    unless acme_settings.private_key?
      session[:app_redirect_to] = lets_encrypt_certificate_path
      redirect_to settings_path(problem_group: :acme, message: :missing_key)
      return
    end

    redirect_to_ownership if current_user.lets_encrypt_accepted_terms?
  end

  def prove_ownership
    certificate = Certificate.find params[:id]
    @csr = certificate.to_csr
    @attempt = AcmeSignAttempt.create_for_certificate(certificate, acme_settings)
    certificate.save!
  rescue Acme::Client::Error::Unauthorized
    current_user.lets_encrypt_accepted_terms = false
    current_user.save!
    redirect_to action: :index
  end

  def validate_token
    challenge = AcmeChallenge.find_by_token_key params[:token]
    return render text: 'Unknown challenge', status: :not_found unless challenge
    render plain: challenge.token_value
  end

  def start_import
    certificate = Certificate.find params[:id]
    attempt = certificate.inflight_acme_sign_attempt
    attempt.last_status = 'unchecked'
    attempt.status_message = nil
    attempt.save!
    AcmeImportJob.perform_later(attempt)
    redirect_to action: :import_status, attempt_id: attempt.id
  end

  def import_status
    certificate = Certificate.find params[:id]
    @attempt = AcmeSignAttempt.find params[:attempt_id]
    raise NotFound unless certificate.id == @attempt.certificate_id
    redirect_to action: :prove_ownership unless @attempt
  end

  def register
    return redirect_to_ownership if current_user.lets_encrypt_accepted_terms?

    registration = acme_client.register contact: "mailto:#{current_user.email}"
    current_user.lets_encrypt_registration_uri = registration.uri
    begin
      registration.agree_terms
      current_user.lets_encrypt_accepted_terms = true
    ensure
      current_user.save!
    end

    redirect_to_ownership
  end

  private

  def load_settings
    @acme_settings = Settings::LetsEncrypt.new
  end

  def invalid_challenge(challenge)
    challenge.delete!
    redirect_to
  end

  def redirect_to_ownership
    redirect_to action: :prove_ownership
  end

  def acme_client
    @acme_client ||= Acme::Client.new private_key: acme_settings.private_key.to_openssl, endpoint: acme_settings.endpoint
  end
end
