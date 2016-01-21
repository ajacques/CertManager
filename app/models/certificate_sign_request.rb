class CertificateSignRequest < ActiveRecord::Base
  belongs_to :certificate
  belongs_to :private_key
  belongs_to :subject
  accepts_nested_attributes_for :subject
  has_many :_subject_alternate_names, class_name: 'SubjectAlternateName'

  def self.from_cert(cert)
    csr = new
    csr.subject = cert.subject
    csr.private_key = cert.private_key
    csr
  end

  def subject_alternate_names=(sans)
    orig = _subject_alternate_names.dup
    new = sans.map { |usage|
      first = orig.find { |k| k.value == usage }
      return first if first
      SubjectAlternateName.new name: usage
    }
    self._subject_alternate_names = new
  end

  def to_openssl
    @csr = OpenSSL::X509::Request.new
    @csr.subject = subject.to_openssl
    @csr.public_key = private_key.to_openssl.public_key
    san_attribute
    @csr
  end

  delegate :signature_algorithm, to: :to_openssl

  delegate :rsa?, to: :private_key

  delegate :bit_length, to: :private_key

  delegate :to_pem, to: :to_openssl

  private

  def san_attribute
    return if _subject_alternate_names.empty?
    sans = _subject_alternate_names.map { |s|
      "DNS:#{s.name}"
    }.join(', ')
    factory = OpenSSL::X509::ExtensionFactory.new
    exts = []
    exts << factory.create_extension('subjectAltName', sans, false)
    ext_req = OpenSSL::ASN1::Set [OpenSSL::ASN1::Sequence(exts)]
    @csr.add_attribute OpenSSL::X509::Attribute.new 'extReq', ext_req
  end
end
