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
  belongs_to :subject, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :subject
  accepts_nested_attributes_for :private_key
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
    chain += private_key.to_pem if include_private and private_key.present?
    if public_key.present?
      chain += public_key.to_pem
    end
    chain += issuer.full_chain(false) if issuer_id.present? and issuer_id != self.id
    chain
  end
  def chain
    [*(issuer.chain if issuer.present? and issuer_id != self.id)] + [self]
  end
  def new_csr
    request = OpenSSL::X509::Request.new
    request.subject = subject.to_openssl
    request.public_key = private_key.to_openssl.public_key
    request
  end
  def sign(cert)
    raise 'Must be a CA cert to sign other certs' unless self.public_key.is_ca?
    raise 'Basic constraints must include keyCertSign' unless self.public_key.key_usage.include? :keyCertSign
    public_key.issuer_subject_id = self.subject_id
    ossl = cert.public_key.to_openssl
    ossl.issuer = self.subject.to_openssl
    ossl.public_key = cert.private_key.to_openssl.public_key
    ossl.sign private_key.to_openssl, public_key.hash_algorithm
    cert.public_key.body = ossl.to_der
    cert
  end
  def touch_by(user)
    self.created_by_id = user.id if not self.created_by_id
    self.updated_by_id = user.id
    self.touch if not new_record?
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
    Certificate.find_or_initialize_by(public_key_id: pub.id) do |r|
      r.public_key = pub
      r.subject = pub.subject
      r.private_key = priv
    end
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