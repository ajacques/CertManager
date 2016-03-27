class PublicKey < ActiveRecord::Base
  has_one :certificate
  belongs_to :subject, autosave: true
  belongs_to :private_key
  belongs_to :issuer_subject, class_name: 'Subject', autosave: true
  has_many :revocation_endpoints, autosave: true
  has_and_belongs_to_many :_subject_alternate_names, join_table: 'public_keys_sans', class_name: 'SubjectAlternateName'
  # has_many :_subject_alternate_names,
  #          through: :san_records, source: :subject_alternate_name, class_name: 'SubjectAlternateName', dependent: :delete_all
  # has_many :san_records, class_name: 'PublicKeysSan', autosave: true
  has_many :key_usages, -> { where(group: 'basic') }, autosave: true, dependent: :destroy
  has_many :extended_key_usages, -> { where(group: 'extended') }, class_name: 'KeyUsage', autosave: true, dependent: :destroy
  accepts_nested_attributes_for :subject
  validates :hash_algorithm, presence: true, inclusion: { in: %w(md2 md5 sha1 sha256 sha384 sha512),
                                                          message: '%{value} is not an expected hash_algorithm' }
  after_initialize :set_defaults

  def to_pem
    "-----BEGIN CERTIFICATE-----\n#{Base64.encode64(body)}-----END CERTIFICATE-----"
  end

  def to_text
    OpenSSL::X509::Certificate.new(body).to_text
  end

  def to_der
    body
  end

  def rsa?
    false
  end

  def ec?
    false
  end

  def to_h
    {
      id: id,
      hash_algorithm: hash_algorithm,
      key_usage: key_usage,
      subject: subject.to_h,
      issuer_subject: issuer_subject.to_h,
      pem: to_pem,
      fingerprint: fingerprint
    }
  end

  delegate :as_json, to: :to_h

  def as_json(opts = {})
    to_h.as_json(opts)
  end

  def to_openssl
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.subject = subject.to_openssl
    cert.not_before = not_before
    cert.not_after = not_after
    cert.serial = OpenSSL::BN.new serial.to_s
    cert.add_extension R509::Cert::Extensions::BasicConstraints.new ca: is_ca
    cert.add_extension R509::Cert::Extensions::KeyUsage.new value: key_usage if key_usage.any?
    cert.add_extension R509::Cert::Extensions::ExtendedKeyUsage.new value: extended_key_usage if extended_key_usage.any?
    cert
  end

  def subject_alternate_names
    _subject_alternate_names.map(&:name)
  end

  def subject_alternate_names=(sans_list)
    orig = _subject_alternate_names.dup
    new = sans_list.map { |usage|
      first = orig.find { |k| k.value == usage }
      return first if first
      SubjectAlternateName.new name: usage
    }
    self._subject_alternate_names = new
  end

  def self.import(pem, &_block)
    r509 = R509::Cert.new cert: pem
    name = if r509.rsa?
             RSAPublicKey
           elsif r509.ec?
             ECPublicKey
           end
    name.find_or_initialize_by(body: r509.to_der) do |r|
      r.import_from_r509 r509
    end
  end

  def import_from_r509(r509)
    self.subject = Subject.from_r509(r509.subject)
    %w(not_before not_after).each do |attrib|
      send("#{attrib}=", r509.send(attrib))
    end
    self.issuer_subject = Subject.from_r509 r509.issuer
    self.is_ca = r509.basic_constraints.try(:is_ca?) || false
    self.key_usage = r509.key_usage.allowed_uses if r509.key_usage
    self.subject_alternate_names = r509.subject_alt_name.names.map(&:value) if r509.subject_alt_name
  end

  def self.generate_key_usage_accessors(name, group)
    plural = name.to_s.pluralize
    define_method(name) do
      send(plural).map do |usage|
        usage.value.to_sym
      end
    end
    define_method("#{name}=") do |usages|
      orig = send(plural).dup
      new = usages.map { |usage|
        first = orig.find { |k| k.value == usage }
        return first if first
        KeyUsage.new value: usage, public_key: self, group: group
      }
      send("#{plural}=", new)
    end
  end

  private

  def set_defaults
    rand = OpenSSL::BN.rand 63
    self.serial ||= rand.to_i
  end

  generate_key_usage_accessors(:key_usage, 'basic')
  generate_key_usage_accessors(:extended_key_usage, 'extended')
end
