require 'digest/sha1'

class Certificate < ActiveRecord::Base
  # Associations
  belongs_to :issuer, class_name: 'Certificate', inverse_of: :sub_certificates
  has_many :sub_certificates, class_name: 'Certificate', foreign_key: 'issuer_id'
  has_many :subject_alternate_names
  belongs_to :public_key
  belongs_to :subject

  # Scopes
  scope :expiring_in, -> time { joins(:public_key).where("public_keys.not_after < ?", Time.now + time) if time.present? }
  scope :owned, -> { where('public_key_id IS NOT NULL AND private_key_data IS NOT NULL') }
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
  def expires_in
    self.public_key.not_after - Time.now
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
  def expires?
    public_key.present?
  end
  def expired?
    expires? and Time.now < self.public_key.not_after
  end

  def to_s
    subject.CN
  end

  def private_key
    R509::PrivateKey.new key: self.private_key_data if self.private_key_data.present?
  end
  def public_key=(key)
    pub = PublicKey.from_r509 key
    pub.save!
    self.public_key_id = pub.id
  end

  def self.with_modulus(modulus)
    modulus_hash = Digest::SHA1.hexdigest(modulus.to_s)
    Certificate.joins(:public_key).where(public_keys: { modulus_hash: modulus_hash })
  end
  def self.new_stub(subject)
    cert = Certificate.new
    cert.subject = Subject.from_r509(subject)
    public_key = PublicKey.new subject: subject.to_s, common_name: subject.CN
    public_key.save!
    cert.public_key_id = public_key.id
    cert
  end
  def self.from_r509(crt)
    cert = Certificate.new
    cert.public_key = crt
    cert.subject = Subject.from_r509(crt.subject)
    cert
  end
end