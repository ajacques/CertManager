class SigningController < ApplicationController
  def configure
    @signee = Certificate.find(params[:another_id])
    @signer = Certificate.find(params[:id])
    @allow_subject_changes = @signer != @signee
    @self_signing = @signer == @signee
    @subject = @signee.subject
    @hash_algorithm = CertManager::SecurityPolicy.hash_algorithm.default
  end

  def sign_cert
    signer = Certificate.find(params[:id])
    signee = Certificate.find(params[:another_id])
    lifetime = 1.year
    if signer.id == signee.id
      subject = signee.subject
    else
      subject = Subject.create subject_params
    end
    hash_algorithm = params[:hash_algorithm]
    csr = R509::CSR.new key: signee.private_key,
      subject: subject.to_r509,
      message_digest: hash_algorithm

    extensions = []
    cert = if signer.id == signee.id
      R509::CertificateAuthority::Signer.selfsign(csr: csr, extensions: extensions)
    else
      ca = R509::CertificateAuthority::Signer.new(ca_cert: {
        cert: signer.public_key.to_r509,
        key: (R509::PrivateKey.new key: signer.private_key_data)
      })
      ca.sign(csr: csr)
    end
    pub_key = PublicKey.from_r509(cert)
    pub_key.save!
    signee.public_key = pub_key
    signee.save!
    DeployCertificateJob.perform_later signee if params[:auto_deploy]
    redirect_to signee
  end
end