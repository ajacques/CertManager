class CertificateSignRequest < ActiveRecord::Base
  belongs_to :certificate
  belongs_to :private_key
  belongs_to :subject
  accepts_nested_attributes_for :subject
  attr_reader :public_key

  def self.from_cert(cert)
    csr = self.new
    csr.subject = cert.subject
    csr.private_key = cert.private_key
    csr.generate_csr
    csr
  end

  def generate_csr
    @csr = OpenSSL::X509::Request.new
    @csr.subject = subject.to_openssl
    @csr.public_key = private_key.to_openssl.public_key
  end

  def subject_alternate_names=(sans)
    sans = sans.map {|s| "DNS:#{s}"}.join(', ')
    factory = OpenSSL::X509::ExtensionFactory.new
    exts = []
    exts << factory.create_extension('subjectAltName', sans, false)
    extReq = OpenSSL::ASN1::Set [OpenSSL::ASN1::Sequence(exts)]
    @csr.add_attribute OpenSSL::X509::Attribute.new('extReq', extReq)
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