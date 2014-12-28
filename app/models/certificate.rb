class Certificate < ActiveRecord::Base
  # Associations
  belongs_to :issuer, class_name: 'Certificate', inverse_of: :sub_certificates
  has_many :sub_certificates, class_name: 'Certificate', foreign_key: 'issuer_id'
  has_many :subject_alternate_names
  has_one :certificate_request

  @issuer_subject = nil
  def issuer_subject=(t)
    @issuer_subject = t
  end
  def issuer_subject
    @issuer_subject
  end

  def to_s
    common_name
  end

  def public_key
    R509::Cert.parse cert: self.public_key_data
  end
  def common_name
    (R509::Subject.new OpenSSL::X509::Name.parse self.subject).CN
  end

  def self.from_r509(crt)
    cert = Certificate.new
    cert.subject = crt.subject
    cert.common_name = crt.subject.CN
    cert.public_key_data = crt.to_pem
    cert.not_before = crt.not_before
    cert.not_after = crt.not_after
    cert
  end
end