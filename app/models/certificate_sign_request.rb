class CertificateSignRequest < ActiveRecord::Base
  belongs_to :certificate
  belongs_to :private_key
  belongs_to :subject
  accepts_nested_attributes_for :subject
  has_many :_subject_alternate_names, class_name: 'SubjectAlternateName'

  def self.from_cert(cert)
    csr = self.new
    csr.subject = cert.subject
    csr.private_key = cert.private_key
    csr
  end
  def subject_alternate_names=(sans)
    orig = self._subject_alternate_names.dup
    new = sans.map do |usage|
      first = orig.select {|k| k.value == usage}.first
      return first if first
      SubjectAlternateName.new name: usage
    end
    self._subject_alternate_names = new
  end

  def to_openssl
    @csr = OpenSSL::X509::Request.new
    @csr.subject = subject.to_openssl
    @csr.public_key = private_key.to_openssl.public_key
    san_attribute
    @csr
  end
  def signature_algorithm
    to_openssl.signature_algorithm
  end
  def rsa?
    private_key.rsa?
  end
  def bit_length
    private_key.bit_length
  end
  def to_pem
    to_openssl.to_pem
  end

  private
  def san_attribute
    return if _subject_alternate_names.empty?
    sans = _subject_alternate_names.map do |s|
      "DNS:#{s.name}"
    end.join(', ')
    factory = OpenSSL::X509::ExtensionFactory.new
    exts = []
    exts << factory.create_extension('subjectAltName', sans, false)
    extReq = OpenSSL::ASN1::Set [OpenSSL::ASN1::Sequence(exts)]
    @csr.add_attribute OpenSSL::X509::Attribute.new 'extReq', extReq
  end
end