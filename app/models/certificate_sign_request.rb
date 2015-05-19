class CertificateSignRequest
  attr_reader :subject, :public_key, :private_key

  def initialize(subject, private_key)
    @subject = subject
    @private_key = private_key
    @csr = OpenSSL::X509::Request.new
    @csr.subject = subject.to_openssl
    @csr.public_key = private_key.to_openssl.public_key
  end

  def self.from_cert(cert)
    self.new cert.subject, cert.private_key
  end

  def signature_algorithm
    @csr.signature_algorithm
  end
  def rsa?
    private_key.rsa?
  end
  def bit_length
    private_key.bit_length
  end
  def to_pem
    @csr.to_pem
  end
end