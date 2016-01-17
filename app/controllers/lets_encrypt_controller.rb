require 'acme/client'

class LetsEncryptController < ApplicationController
  # Specification: https://letsencrypt.github.io/acme-spec/
  def index
    redirect_to action: :prove_ownership if current_user.lets_encrypt_accepted_terms?
    @keys = RSAPrivateKey.all
  end

  def prove_ownership
    certificate = Certificate.find params[:id]
    render plain: certificate.subject
  end

  def register
    private_key = PrivateKey.find params[:client_key]
    registration = acme_client.register contact: "mailto:#{current_user.email}"
    current_user.lets_encrypt_key = private_key
    current_user.lets_encrypt_accepted_terms = true
    current_user.save!
  end

  private
  def acme_client
    @acme_client ||= Acme::Client.new private_key: private_key.to_openssl, endpoint: 'http://acme-test.devvm'
  end
end
