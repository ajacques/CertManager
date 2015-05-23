class Certificate < ActiveRecord::Base
  # Associations
  attr_accessor :issuer_subject
  belongs_to :issuer, class_name: 'Certificate', inverse_of: :sub_certificates, autosave: true
  has_many :sub_certificates, -> { where('certificates.issuer_id != certificates.id') }, class_name: 'Certificate', foreign_key: 'issuer_id'
  has_many :services
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  belongs_to :private_key, autosave: true
  belongs_to :public_key, autosave: true
  has_one :csr, class_name: 'CertificateSignRequest'
  accepts_nested_attributes_for :private_key
  accepts_nested_attributes_for :csr
  before_save :refresh_hash

  include HasPublicKey

  # Scopes
  scope :expiring_in, -> time { joins(:public_key).where('public_keys.not_after < ? ', Time.now + time) if time.present? }
  scope :expired, -> { joins(:public_key).where('public_keys.not_after < ?', Time.now) }
  scope :owned, -> { where('certificates.private_key_id IS NOT NULL') }
  scope :signed, -> { where('certificates.public_key_id IS NOT NULL') }
  scope :leaf, -> { where('(SELECT COUNT(*) FROM certificates AS sub WHERE sub.issuer_id = certificates.id) == 0') }
  scope :with_subject, -> subject { Certificate.joins(:subject).where(subjects: Subject.filter_params(subject.to_h)) }
  scope :can_sign, -> { joins(:public_key).where(public_keys: { is_ca: true })}

  def status
    if private_key.present? and public_key.present?
      'Signed'
    elsif private_key.present?
      'Unsigned'
    elsif public_key.present?
      'Public Only'
    else
      'Stub'
    end
  end

  def subject
    base = public_key || csr
    base.subject
  end

  def to_s
    subject.to_s || 'No Subject'
  end
  def to_h
    hash = {
     id: id,
     subject: subject.to_h.stringify_keys
    }
    hash[:public_key] = public_key.to_h if public_key
    hash[:private_key] = private_key.to_h
    hash[:crl_endpoints] = crl_endpoints if crl_endpoints
    hash
  end
  def as_json(param)
    to_h.as_json(param)
  end
  def full_chain(include_private=false)
    chain = ''
    chain += "#{private_key.to_pem}\n" if include_private and private_key.present?
    chain += "#{public_key.to_pem}\n" if public_key
    chain += issuer.full_chain(false) if issuer_id.present? and issuer_id != self.id
    chain
  end
  def chain
    [*(issuer.chain if issuer.present? and issuer_id != self.id)] + [self]
  end
  def new_csr
    CertificateSignRequest.from_cert self
  end
  def sign(cert)
    raise 'Must be a CA cert to sign other certs' unless self.public_key.is_ca?
    raise 'Basic constraints must include keyCertSign' unless self.public_key.key_usage.include? :keyCertSign
    public_key.issuer_subject_id = self.subject.id
    ossl = cert.public_key.to_openssl
    ossl.issuer = self.subject.to_openssl
    ossl.public_key = cert.private_key.to_openssl.public_key
    ossl.sign private_key.to_openssl, public_key.hash_algorithm
    cert.public_key.body = ossl.to_der
    cert
  end
  def touch_by(user)
    self.created_by_id = user.id unless self.created_by_id
    self.updated_by_id = user.id
    self.touch unless new_record?
  end
  def touch_by!(user)
    touch_by user
    save!
  end

  def self.with_modulus(modulus)
    modulus_hash = Digest::SHA1.hexdigest(modulus.to_s)
    Certificate.joins(:public_key).where(public_keys: { modulus_hash: modulus_hash })
  end
  def self.new_stub(subject)
    cert = Certificate.new
    cert.subject = Subject.from_r509(subject)
    cert
  end
  def self.find_by_common_name(name)
    Certificate.joins(public_key: :subject).where(subjects: {CN: name })
  end
  def self.find_for_key_pair(pub, priv)
    cert1 = Certificate.find_by_public_key_id pub.id if pub
    cert2 = Certificate.find_by_private_key_id priv.id if priv
    cert3 = Certificate.find_by_subject_id pub.subject.id if pub
    cert = cert1 || cert2 || cert3
    if not cert and pub
      cert = Certificate.joins(:private_key).where(private_keys: {fingerprint: pub.fingerprint}).first
    end
    if not cert and priv
      cert = Certificate.joins(:public_key).where(public_keys: {fingerprint: priv.fingerprint}).first
    end
    unless cert
      cert = Certificate.new
      cert.subject = pub.subject
    end
    cert.public_key = pub if pub
    cert.private_key = priv if priv
    cert
  end
  def self.import(crt)
    r509 = R509::Cert.new(cert: crt)
    cert = Certificate.with_subject(r509.subject).first
    if cert.nil?
      cert = Certificate.new
    end
    cert.public_key = PublicKey.import(crt)
    cert.subject = cert.public_key.subject
    cert
  end

  private
  def refresh_hash
    self.chain_hash = Digest::SHA256.hexdigest(self.full_chain(true))
  end
end