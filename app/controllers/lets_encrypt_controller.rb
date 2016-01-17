require 'acme/client'

class LetsEncryptController < ApplicationController
  # Specification: https://letsencrypt.github.io/acme-spec/
  def index
    return redirect_to_ownership if current_user.lets_encrypt_accepted_terms?
    @keys = RSAPrivateKey.all
  end

  def prove_ownership
    # TODO: Persist challenges so we don't keep fetching them from the server
    certificate = Certificate.find params[:id]
    @challenges = LetsEncryptChallenge.find_by_certificate_id certificate.id
    unless @challenges
      domain = certificate.domain_names.first
      authorization = acme_client.authorize(domain: domain)
      challenge = authorization.http01
      @challenges = []
      @challenges << LetsEncryptChallenge.create!(certificate: certificate, domain_name: domain, private_key: current_user.lets_encrypt_key, token_key: challenge.filename, token_value: challenge.file_content)
    end

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
  def redirect_to_ownership
    redirect_to action: :prove_ownership
  end
  def acme_client
    @acme_client ||= Acme::Client.new private_key: current_user.lets_encrypt_key.to_openssl, endpoint: 'http://acme-test.devvm'
  end
end
