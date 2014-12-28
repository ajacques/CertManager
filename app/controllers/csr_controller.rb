class CsrController < ApplicationController
  def new
    subject = R509::Subject.new
    subject.CN = params[:common_name]
    subject.O = params[:org_name]
    subject.C = params[:country]
    csr_x = R509::CSR.new(subject: subject)
    csr = CertificateRequest.from_r509 csr_x
    cert = Certificate.new
    cert.subject = subject.to_s
    cert.common_name = subject.CN
    cert.certificate_request = csr
    cert.private_key_data = csr.key
    cert.save!
    csr.save!
    redirect_to cert
  end
end