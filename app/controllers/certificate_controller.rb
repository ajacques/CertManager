require 'app/ocsp'

include CertificateHelper
include CrlHelper

class CertificateController < ApplicationController
  def index
    @certs = Certificate.all
  end

  def show
    @cert = Certificate.find(params[:id])
  end

  def new
  end

  def csr
    @cert = Certificate.find(params[:id])
    @csr = R509::CSR.new key: @cert.private_key, subject: @cert.subject
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

  def do_import
    certs = CertificateHelper.extract_certificates(params[:key])
    keys = CertificateHelper.extract_private_keys(params[:key])

    certs = certs.map { |key|
      # This should be moved to a Certificate.merge! method
      cert = Certificate.from_r509(key)
      cert.issuer_subject = key.issuer
      tmp = Certificate.joins(:public_key).where(public_keys: { common_name: key.subject.CN }).first
      if tmp.present?
        tmp.public_key = key
        tmp.save!
        tmp.issuer_subject = cert.issuer_subject
      else
        cert.save!
      end
      tmp || cert
    }
    certs.each { |cert|
      if cert.issuer.nil?
        cert.issuer = Certificate.joins(:public_key).where(public_keys: { subject: cert.issuer_subject.to_s }).first
        if cert.issuer.nil?
          issuer = Certificate.new_stub cert.issuer_subject
          issuer.save!
          cert.issuer = issuer
        end
        cert.save! if cert.issuer.present?
      end
    }
    keys.each { |key|
      cert = Certificate.with_modulus(key.key.params['n'])
      if cert.present?
        cert.private_key_data = key.to_pem
        cert.save!
      end
    }
    render plain: certs.inspect
  end
end