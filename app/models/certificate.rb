require 'digest/sha1'

class Certificate < ActiveRecord::Base
  # Associations
  belongs_to :issuer, class_name: 'Certificate', inverse_of: :sub_certificates, autosave: true
  has_many :sub_certificates, class_name: 'Certificate', foreign_key: 'issuer_id'
  has_many :subject_alternate_names, autosave: true
  has_many :services
  belongs_to :public_key, autosave: true
  belongs_to :subject, autosave: true
  before_save :refresh_hash

  # Scopes
  scope :expiring_in, -> time { joins(:public_key).where("public_keys.not_after < ?", Time.now + time) if time.present? }
  scope :owned, -> { where('private_key_data IS NOT NULL') }
  scope :leaf, -> { where('(SELECT COUNT(*) FROM certificates AS sub WHERE sub.issuer_id = certificates.id) == 0') }

  @issuer_subject = nil
  def issuer_subject=(t)
    @issuer_subject = t
  end
  def issuer_subject
    @issuer_subject
  end
  def status
    if private_key.present? and public_key.present?
      'Signed'
    elsif private_key.present?
      'Unsigned'
    elsif public_key.present?
      'No Key'
    else
      'Stub'
    end
  end
  def crl_endpoints
    return nil if self.public_key.nil?
    self.public_key.crl_distribution_points.uris
  end
  def ocsp_endpoints
    return nil if self.public_key.nil?
    self.public_key.authority_info_access.ocsp.names.map {|obj|
      obj.value
    }
  end
  def expires_in
    return 9999999.years if not expires?
    self.public_key.not_after - Time.now
  end
  def expires?
    public_key.present?
  end
  def expired?
    expires? and Time.now < self.public_key.not_after
  end
  def signed?
    issuer_id.present?
  end
  def full_chain(include_private=false)
    chain = ''
    chain += private_key.to_pem if include_private and private_key
    chain += public_key.to_pem
    chain += issuer.full_chain(false) if issuer_id.present? and issuer_id != self.id
    chain
  end

  def to_s
    subject.CN
  end

  def private_key
    R509::PrivateKey.new key: self.private_key_data if self.private_key_data.present?
  end

  def self.with_modulus(modulus)
    modulus_hash = Digest::SHA1.hexdigest(modulus.to_s)
    Certificate.joins(:public_key).where(public_keys: { modulus_hash: modulus_hash })
  end
  def self.new_stub(subject)
    cert = Certificate.new
    cert.subject = Subject.from_r509(subject)
    public_key = PublicKey.new subject: cert.subject
    cert.public_key = public_key
    cert
  end
  def self.from_r509(crt)
    cert = Certificate.new
    cert.public_key = PublicKey.from_r509(crt)
    cert.subject = Subject.from_r509(crt.subject)
    crt.san.names.each do |san|
      san = SubjectAlternateName.new name: san.value
      cert.subject_alternate_names << san
    end if crt.san
    cert
  end
  def self.with_subject_name(name)
    Certificate.joins(public_key: :subject).where(subjects: {CN: name })
  end
  def self.find_or_create(crt)
    if crt.is_a?(R509::Cert)
      Certificate.joins(:subject).where(subjects: { CN: crt.subject.CN }).first_or_initialize do |cert|
        cert.public_key = PublicKey.from_r509(crt)
        cert.subject = Subject.from_r509(crt.subject)
        crt.san.names.each do |san|
          san = SubjectAlternateName.new name: san.value
          cert.subject_alternate_names << san
        end if crt.san
      end
    end
  end

  private
  def refresh_hash
    self.chain_hash = Digest::SHA256.hexdigest(self.full_chain(true))
  end
end