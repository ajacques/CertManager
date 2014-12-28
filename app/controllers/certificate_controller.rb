include CertificateHelper

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
    @csr = @cert.certificate_request
  end

  def do_import
    keys = CertificateHelper.extract_certificates(params[:key])

    certs = keys.map { |key|
      cert = Certificate.from_r509(key)
      cert.issuer_subject = key.issuer
      puts "TEST #{key.issuer.inspect}"
      tmp = Certificate.where(common_name: key.subject.CN).first
      if tmp.present?
        tmp.public_key_data = key.to_pem
        tmp.not_before = key.not_before
        tmp.not_after = key.not_after
        tmp.save!
        tmp.issuer_subject = cert.issuer_subject
      else
        cert.save!
      end
      tmp || cert
    }
    certs.each { |cert|
      if cert.issuer.nil?
        cert.issuer = Certificate.where(subject: cert.issuer_subject.to_s).first
        if cert.issuer.nil?
          issuer = Certificate.new subject: cert.issuer_subject.to_s, common_name: cert.issuer_subject.CN
          issuer.save!
          cert.issuer = issuer
        end
        cert.save! if cert.issuer.present?
      end
    }
    render plain: certs.inspect
  end
end