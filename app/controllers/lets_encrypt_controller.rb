require 'acme/client'

class LetsEncryptController < ApplicationController
  skip_before_action :require_login, only: [:validate_token]
  # Specification: https://letsencrypt.github.io/acme-spec/
  def index
    return redirect_to_ownership if current_user.lets_encrypt_accepted_terms?
    @keys = RSAPrivateKey.all
  end

  def prove_ownership
    @certificate = Certificate.find params[:id]
    settings = Settings::LetsEncrypt.new
    2.times do
      @challenge = AcmeChallenge.for_certificate(@certificate, settings)
      break if (not @challenge.expired?) && @challenge.valid_challenge?
      @challenge.delete
    end
    redirect_to action: :verify_done if @challenge.status.valid?
  rescue Acme::Client::Error::NotFound
    @challenge.delete
    # Possible infinite redirect loop?
    return redirect_to_ownership
  end

  def validate_token
    challenge = AcmeChallenge.find_by_token_key params[:token]
    return render text: 'Unknown challenge', status: :not_found unless challenge
    render plain: challenge.token_value
  end

  def formal_verification
    @certificate = Certificate.find params[:id]
    challenge = AcmeChallenge.find_by_certificate_id @certificate.id
    status = challenge.status
    if status.valid?
      redirect_to action: :verify_done
    elsif status.pending?
      raise 'Failed to verify' unless challenge.request_verification
    else
      redirect_to verification_failed_certificate_path
    end
  end

  def verification_failed
    @certificate = Certificate.find params[:id]
    challenge = AcmeChallenge.find_by_certificate_id @certificate.id
    @status = challenge.status
  end

  def sign_csr
    certificate = Certificate.find params[:id]
    signed = acme_client.new_certificate certificate.csr
    public_key = PublicKey.import signed.to_pem
    certificate.public_key = public_key
    public_key.private_key = certificate.private_key
    challenge = AcmeChallenge.find_by_certificate_id @certificate.id
    challenge.delete
    certificate.save!
    redirect_to certificate
  end

  def register
    return redirect_to_ownership if current_user.lets_encrypt_accepted_terms?

    private_key = PrivateKey.find params[:client_key]
    current_user.lets_encrypt_key = private_key
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
