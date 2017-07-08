class CertificateSignRequest < ApplicationRecord
  belongs_to :certificate
  belongs_to :private_key
  belongs_to :subject
  accepts_nested_attributes_for :subject
  has_and_belongs_to_many :_subject_alternate_names, join_table: 'csr_sans', class_name: 'SubjectAlternateName'
  # has_many :subject_alternate_names, through: :csr_sans, autosave: true
  # has_many :csr_sans, autosave: true

  delegate :signature_algorithm, to: :to_openssl
  delegate :rsa?, to: :private_key
  delegate :bit_length, to: :private_key
  delegate :to_pem, to: :to_openssl
  delegate :to_der, to: :to_openssl

  def self.from_cert(cert)
    csr = new
    csr.certificate = cert
    csr.subject = cert.subject
    csr.private_key = cert.private_key
    csr.subject_alternate_names = (cert.public_key || cert.csr).subject_alternate_names
    csr
  end

  def domain_names
    ([subject.CN] + subject_alternate_names).uniq
  end

  def subject_alternate_names
    _subject_alternate_names.map(&:name)
  end

  def subject_alternate_names=(san_list)
    orig = _subject_alternate_names
    new = san_list.map { |usage|
      first = orig.find { |k| k.value == usage }
      return first if first
      SubjectAlternateName.new name: usage
    }
    self._subject_alternate_names = new
  end

  delegate :to_text, to: :to_openssl

  def to_openssl
    csr = OpenSSL::X509::Request.new
    csr.subject = subject.to_openssl
    csr.public_key = private_key.to_openssl.public_key
    exts = []
    exts << san_attribute if san_attribute
    ext_req = OpenSSL::ASN1::Set [OpenSSL::ASN1::Sequence(exts)]
    csr.add_attribute(OpenSSL::X509::Attribute.new('extReq', ext_req))
    csr.sign private_key.to_openssl, hash_algorithm.new
    csr
  end

  def hash_algorithm
    OpenSSL::Digest::SHA256
  end

  private

  def san_attribute
    return if subject_alternate_names.empty?
    sans = subject_alternate_names.map { |s|
      "DNS:#{s}"
    }.join(', ')
    factory = OpenSSL::X509::ExtensionFactory.new
    factory.create_extension('subjectAltName', sans, false)
  end
end
