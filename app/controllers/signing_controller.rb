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
      subject = Subject.create (Subject.filter_params(params[:subject])).permit(:O, :OU, :S, :C, :CN, :L, :ST) # TODO: Move permitted attributes into a separate file
    end
    hash_algorithm = params[:hash_algorithm]
    csr = R509::CSR.new key: signee.private_key.to_pem,
      subject: subject.to_r509,
      message_digest: hash_algorithm

    extensions = []
    extensions << R509::Cert::Extensions::BasicConstraints.new(ca: (params[:attributes][:ca]) == '1')
    cert = if signer.id == signee.id
      R509::CertificateAuthority::Signer.selfsign(csr: csr, extensions: extensions, message_digest: hash_algorithm)
    else
      config = R509::Config::CAConfig.new(ca_cert: R509::Cert.new(cert: signer.public_key.to_pem, key: signer.private_key.to_pem))
      ca = R509::CertificateAuthority::Signer.new config
      ca.sign(
        csr: csr,
        extensions: extensions,
        message_digest: hash_algorithm
      )
    end
    pub_key = PublicKey.from_r509(cert)
    signee.public_key = pub_key
    signee.issuer = signer
    signee.save!
    DeployCertificateJob.perform_later signee if params[:auto_deploy]
    redirect_to signee
  end
end