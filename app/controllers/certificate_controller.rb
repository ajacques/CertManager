require 'app/ocsp'

include CertificateHelper
include CrlHelper

class CertificateController < ApplicationController
  def index
    @certs = Certificate.owned
    @expiring = Certificate.expiring_in(7.days)
  end

  def show
    @cert = Certificate.find(params[:id])
    if @cert.public_key
      respond_to do |format|
        format.pem {
          render plain: @cert.public_key.to_pem
        }
        format.html {
          render 'show'
        }
      end
    else
      render 'show_csr'
    end
  end

  def new
  end

  def create
    private_key = R509::PrivateKey.new bit_length: params[:bit_length].to_i
    subject_model = Subject.create(subject_params)
    cert = Certificate.new
    cert.subject = subject_model
    cert.private_key_data = private_key.to_pem

    ActiveRecord::Base.transaction do
      subject_model.save!
      cert.save!
    end

    redirect_to cert
  end

  def csr
    @cert = Certificate.find(params[:id])
    @csr = R509::CSR.new key: @cert.private_key, subject: @cert.subject.to_r509
    render 'csr/show'
  end

  def revocation_check
    cert = Certificate.find(params[:id])
    result = CrlHelper.check_status(cert)
    result << OcspFetcher.fetch_ocsp('http://ocsp.comodoca.com/', cert)

    respond_to do |format|
      format.json {
        render plain: result.to_json
      }
    end
  end

  def sign_cert
    @signee = Certificate.find(params[:another_id])
    if @signee.signer then
      render 'already_signed'
    else
      @signer = Certificate.find(params[:id])
      @allow_subject_changes = @signer != @signee
      @lifetime = 1.year
      @subject = @signee.subject
      @hash_algorithm = CertManager::SecurityPolicy.hash_algorithms.default
    end
  end

  def do_sign_cert
    @signer = Certificate.find(params[:id])
    @signee = Certificate.find(params[:another_id])
    @allow_subject_changes = @signer != @signee
    @lifetime = 1.year
    @subject = if params[:subject]
      Subject.create subject_params
    else
      @signee.subject
    end
    @hash_algorithm = params[:hash_algorithm] || 'sha1' # Don't hard code this
    @csr = R509::CSR.new key: @signee.private_key,
      subject: @subject.to_r509,
      message_digest: @hash_algorithm

    cert = if @signer.id == @signee.id
      R509::CertificateAuthority::Signer.selfsign(csr: @csr)
    else
      ca = R509::CertificateAuthority::Signer.new(ca_cert: {
      cert: @signer.public_key.to_r509,
      key: (R509::PrivateKey.new key: @signer.private_key_data)
      })
      ca.sign(csr: @csr)
    end
    render plain: cert
  end

  def do_import
    certs = CertificateHelper.extract_certificates(params[:key])
    keys = CertificateHelper.extract_private_keys(params[:key])

    # Welcome to hell
    certs = certs.map { |key|
      # This should be moved to a Certificate.merge! method
      cert = Certificate.from_r509(key)
      cert.issuer_subject = key.issuer
      tmp = Certificate.joins(:subject).where(subjects: { CN: key.subject.CN }).first
      if tmp.present?
        tmp.public_key = key
        tmp.save!
        tmp.issuer_subject = cert.issuer_subject
      else
        cert.subject.save!
        cert.save!
      end
      tmp || cert
    }
    certs.each { |cert|
      if cert.issuer.nil?
        cert.issuer = Certificate.joins(:public_key => :subject).where(subjects: {CN: cert.issuer_subject.CN.to_s }).first
        if cert.issuer.nil?
          issuer = Certificate.new_stub cert.issuer_subject
          issuer.save!
          cert.issuer = issuer
        end
        cert.save! if cert.issuer.present?
      end
    }
    keys.each { |key|
      cert = Certificate.with_modulus(key.key.params['n']).first
      if cert.present?
        cert.private_key_data = key.to_pem
        cert.save!
      end
    }
    if params[:return_url]
      redirect_to params[:return_url]
    else
      render plain: certs.inspect
    end
  end
  def subject_params
    params[:subject].permit(:O, :OU, :C, :CN) if params[:subject]
  end
end