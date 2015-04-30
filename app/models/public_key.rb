class PublicKey < ActiveRecord::Base
  has_one :certificate
  belongs_to :subject, autosave: true
  belongs_to :private_key
  belongs_to :issuer_subject, class_name: 'Subject', autosave: true
  has_many :revocation_endpoints, autosave: true
  has_many :subject_alternate_names, autosave: true, dependent: :delete_all
  has_many :key_usages, -> { where(group: 'basic') }, autosave: true, dependent: :destroy
  has_many :extended_key_usages, -> { where(group: 'extended') }, class_name: 'KeyUsage', autosave: true, dependent: :destroy
  accepts_nested_attributes_for :subject
  validates :key_type, presence: true, inclusion: { in: %W(rsa ec), message: '%{value} is not a supported key type' }
  validates :bit_length, numericality: { only_integer: true, greater_than: 0 }, if: :rsa?
  validates :hash_algorithm, presence: true, inclusion: { in: %W(md2 md5 sha1 sha256 sha384 sha512), message: '%{value} is not an expected hash_algorithm' }
  after_initialize :set_defaults

  def to_pem
    "-----BEGIN CERTIFICATE-----\n#{Base64.encode64(self.body)}-----END CERTIFICATE-----"
  end
  def to_text
    OpenSSL::X509::Certificate.new(self.body).to_text
  end
  def to_der
    self.body
  end
  def rsa?
    key_type == 'rsa'
  end
  def to_h
    {
     hash_algorithm: hash_algorithm,
     key_usage: self.key_usage
    }
  end
  def to_openssl
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.subject = subject.to_openssl
    cert.not_before = not_after
    cert.not_after = not_after
    cert.serial = serial
    cert.add_extension R509::Cert::Extensions::BasicConstraints.new ca: is_ca
    cert.add_extension R509::Cert::Extensions::KeyUsage.new value: key_usage unless key_usage.empty?
    cert.add_extension R509::Cert::Extensions::ExtendedKeyUsage.new value: extended_key_usage unless extended_key_usage.empty?
    cert
  end

  def self.from_pem(pem)
    r509 = R509::Cert.new cert: pem
    PublicKey.find_or_initialize_by(body: r509.to_der) do |r|
      r.subject = Subject.from_r509(r509.subject)
      %w(not_before not_after bit_length).each do |attrib|
        r.send("#{attrib}=", r509.send(attrib))
      end
      r.key_type = r509.key_algorithm.downcase
      r.hash_algorithm = r509.signature_algorithm[0, r509.signature_algorithm.index('With')]
      r.issuer_subject = Subject.from_r509 r509.issuer
      r.is_ca = r509.basic_constraints.try(:is_ca?)
      r.key_usage = r509.key_usage.allowed_uses if r509.key_usage
    end
  end
  def self.from_private_key(key)
    pub = PublicKey.new private_key_id: key.id
    %w(key_type curve_name bit_length).each do |attrib|
      pub.send("#{attrib}=", key.send(attrib))
    end
    pub
  end

  private
  def self.generate_key_usage_accessors(name, group)
    plural = name.to_s.pluralize
    define_method(name) do
      self.send(plural).map do |usage|
        usage.value.to_sym
      end
    end
    define_method("#{name}=") do |usages|
      orig = self.send(plural).dup
      new = usages.map do |usage|
        first = orig.select {|k| k.value == usage}.first
        return first if first
        KeyUsage.new value: usage, public_key: self, group: group
      end
      self.send("#{plural}=", new)
    end
  end
  def set_defaults
    self.serial ||= 1
  end

  generate_key_usage_accessors(:key_usage, 'basic')
  generate_key_usage_accessors(:extended_key_usage, 'extended')
end
