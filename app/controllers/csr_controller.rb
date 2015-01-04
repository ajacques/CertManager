class CsrController < ApplicationController
  def new
    subject = R509::Subject.new
    subject.CN = params[:common_name]
    subject.O = params[:org_name]
    subject.OU = params[:department_name]
    subject.C = params[:country]

    private_key = R509::PrivateKey.new
    csr = CertificateRequest.from_subject subject
    cert = Certificate.from_subject subject
    cert.private_key_data = private_key.to_pem
    cert.save!
    redirect_to cert
  end
end