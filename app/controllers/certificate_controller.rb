include CrlHelper

class CertificateController < ApplicationController
  before_action :require_login

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
    cert.save!

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
    @hash_algorithm = params[:hash_algorithm] || CertManager::SecurityPolicy.hash_algorithms.default
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
    certs = CertificateTools.extract_certificates(params[:key])
    keys = CertificateTools.extract_private_keys(params[:key])

    certs.uniq!
    # Welcome to hell
    @certs = certs.map {|cert2|
      cert3 = R509::Cert.new cert: cert2
      cert = Certificate.import cert2
      cert.issuer_subject = cert3.issuer
      cert.save!
      cert
    }
    keys.each { |key|
      pkey = R509::PrivateKey.new key: key
      cert = @certs.find {|c|
          c.public_key.modulus_hash == Digest::SHA1.hexdigest(pkey.key.params['n'].to_s) if c.public_key
        } #c.Certificate.with_modulus(key.key.params['n']).first
      if cert.present?
        cert.private_key_data = pkey.to_pem
      end
    }
    ActiveRecord::Base.transaction do
      @certs.each { |cert|
        if cert.issuer.nil?
          issuer = Certificate.find_by_subject(cert.issuer_subject).first
          if issuer.present?
            cert.issuer = issuer
          else
            cert.issuer = Certificate.new_stub(cert.issuer_subject)
          end
        end
        cert.save!
      }
    end
    if params[:return_url]
      redirect_to params[:return_url]
    else
      render 'import_done'
    end
  end

  private
  def subject_params
    params[:subject].permit(:O, :OU, :C, :CN) if params[:subject]
  end
end