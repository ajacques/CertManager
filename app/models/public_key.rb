class PublicKey < ActiveRecord::Base
  has_one :certificate
  belongs_to :subject, autosave: true
  belongs_to :private_key
  belongs_to :issuer_subject, class_name: 'Subject', autosave: true
  has_many :revocation_endpoints, autosave: true
  has_many :subject_alternate_names, autosave: true, dependent: :delete_all
  accepts_nested_attributes_for :subject
  validates :key_type, presence: true, inclusion: { in: %W(rsa ec), message: '%{value} is not a supported key type' }
  validates :bit_length, numericality: { only_integer: true, greater_than: 0 }, if: :rsa?
  validates :hash_algorithm, presence: true, inclusion: { in: %W(md2 md5 sha1 sha256 sha384 sha512), message: '%{value} is not an expected hash_algorithm' }
  after_initialize :set_defaults

  def to_pem
    "-----BEGIN CERTIFICATE-----\n#{Base64.encode64(self.body)}-----END CERTIFICATE-----"
  end
  def rsa?
    key_type == 'rsa'
  end
  def to_h
    {
     certificate_id: certificate_id,
     hash_algorithm: hash_algorithm,
     subject: subject.to_h,
     private_key_id: private_key_id,
     pem: to_pem
    }
  end
  def to_openssl
    cert = OpenSSL::X509::Certificate.new
    cert.subject = subject.to_openssl
    cert.not_before = not_after
    cert.not_after = not_after
    cert.add_extension R509::Cert::Extensions::BasicConstraints.new(ca: is_ca)
    cert
  end

  def create_csr
    R509::CSR.new({
      type: key_type,
      key: private_key.to_pem,
      subject: subject.to_r509,
      message_digest: hash_algorithm
    })
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
  def set_defaults
    self.is_ca ||= false
  end
end
