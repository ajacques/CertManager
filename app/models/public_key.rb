class PublicKey < ActiveRecord::Base
  has_one :certificate
  belongs_to :subject, autosave: true
  belongs_to :private_key
  has_many :revocation_endpoints, autosave: true
  has_many :extensions, class_name: 'CertificateExtension', autosave: true
  accepts_nested_attributes_for :subject
  accepts_nested_attributes_for :extensions
  validates :key_type, inclusion: { in: %W(rsa), message: '%{value} is not a supported key type' }

  def to_pem
    self.body
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

  def self.from_r509(crt)
    PublicKey.find_or_initialize_by(body: crt.to_pem) do |r|
      r.subject = Subject.from_r509(crt.subject)
      %w(not_before not_after hash_algorithm bit_length).each do |attrib|
        r.send("#{attrib}=", crt.send(attrib))
      end
      crt.crl_distribution_points.uris.each do |uri|
        r.revocation_endpoints << RevocationEndpoint.find_or_initialize_by(uri_type: 'crl', endpoint: uri)
      end if crt.crl_distribution_points.present?
      r.modulus_hash = crt.fingerprint
    end
  end
  def self.from_private_key(key)
    pub = PublicKey.new private_key_id: key.id
    %w(key_type curve_name bit_length).each do |attrib|
      pub.send("#{attrib}=", key.send(attrib))
    end
    pub
  end
end
