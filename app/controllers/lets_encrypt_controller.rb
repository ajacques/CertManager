require 'acme/client'

class LetsEncryptController < ApplicationController
  skip_before_action :require_login, only: [:validate_token]
  # Specification: https://letsencrypt.github.io/acme-spec/
  def index
    redirect_to_ownership if current_user.lets_encrypt_accepted_terms?
  end

  def prove_ownership
    @certificate = Certificate.find params[:id]
    settings = Settings::LetsEncrypt.new
    @challenge = AcmeChallenge.for_certificate(@certificate, settings)
    redirect_to @certificate if @challenge.status.imported?
  end

  def validate_token
    challenge = AcmeChallenge.find_by_token_key params[:token]
    return render text: 'Unknown challenge', status: :not_found unless challenge
    render plain: challenge.token_value
  end

  def start_import
    certificate = Certificate.find params[:id]
    AcmeImportJob.perform_later(certificate)
    redirect_to action: :import_status
  end

  def import_status
    challenge = AcmeChallenge.find_by_certificate_id params[:id]
    redirect_to challenge.certificate if challenge.status.imported?
  end

  def verification_failed
    certificate = Certificate.find params[:id]
    challenge = AcmeChallenge.find_by_certificate_id certificate.id
    @status = challenge.status
  end

  def register
    return redirect_to_ownership if current_user.lets_encrypt_accepted_terms?

    registration = acme_client.register contact: "mailto:#{current_user.email}"
    registration.agree_terms
    current_user.lets_encrypt_accepted_terms = true
    current_user.save!

    redirect_to_ownership
  end

  private

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

  def acme_settings
    Settings::LetsEncrypt.new
  end
end
