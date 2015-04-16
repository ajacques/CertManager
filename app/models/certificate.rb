require 'digest/sha1'

class Certificate < ActiveRecord::Base
  # Associations
  attr_accessor :issuer_subject
  belongs_to :issuer, class_name: 'Certificate', inverse_of: :sub_certificates, autosave: true
  has_many :sub_certificates, class_name: 'Certificate', foreign_key: 'issuer_id'
  has_many :subject_alternate_names, autosave: true, dependent: :delete_all
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
      'No Key'
    else
      'Stub'
    end
  end

  def to_s
    subject.to_s || 'No Subject'
  end
  def as_json(param)
    json = {
      id: id,
      subject: subject
    }
    json[:public_key] = nil
    json.merge! ({
      public_key: {
        pem: public_key.to_pem
      },
      alternate_names: subject_alternate_names.map {|r| r.name},
      ocsp: ocsp_endpoints,
      issuer: ({
        id: issuer.id,
        subject: issuer.subject
      } if issuer.present?),
      not_before: public_key.not_before,
      not_after: public_key.not_after
    }) if public_key.present?
    json[:private_key] = private_key
    json[:crl_endpoints] = crl_endpoints if crl_endpoints
    json.as_json(param)
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
    R509::CSR.new key: private_key.to_pem, subject: subject.to_r509
  end
  def sign(public_key)
    raise 'Must be a CA cert to sign other certs' unless self.public_key.is_ca?
    public_key.issuer_subject_id = self.subject_id
    cert = public_key.to_openssl
    cert.sign private_key.to_openssl, public_key.hash_algorithm
    public_key.body = cert.to_s
    cert
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
  def self.import(crt)
    r509 = R509::Cert.new(cert: crt)
    cert = Certificate.with_subject(r509.subject).first
    if cert.nil?
      cert = Certificate.new
    else
      cert.subject_alternate_names.clear
    end
    cert.public_key = PublicKey.from_pem(crt)
    cert.subject = Subject.from_r509(r509.subject)
    r509.san.names.each do |san|
      san = SubjectAlternateName.new name: san.value
      cert.subject_alternate_names << san
    end if r509.san
    cert
  end

  private
  def refresh_hash
    self.chain_hash = Digest::SHA256.hexdigest(self.full_chain(true))
  end
end