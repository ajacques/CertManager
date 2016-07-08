class ECPrivateKey < PrivateKey
  validates :curve_name, presence: true, inclusion: { in: %w(secp384r1) }
  after_initialize :generate_key
  before_save :update_fingerprint, if: :body_changed?

  def ec?
    true
  end

  def to_openssl
    OpenSSL::PKey::EC.new body
  end

  delegate :group, to: :to_openssl
  delegate :dsa_sign_asn1, to: :to_openssl
  delegate :dsa_verify_asn1, to: :to_openssl

  def to_pem
    "-----BEGIN EC PRIVATE KEY-----\n#{Base64.encode64(body)}-----END EC PRIVATE KEY-----"
  end

  def public_key
    opub = to_openssl.public_key.group.to_der
    ECPublicKey.new private_key: self, curve_name: curve_name, body: opub
  end

  def create_public_key
    key = ECPublicKey.new slice(:curve_name)
    key.private_key = self
    key
  end

  private

  def generate_key
    if valid? && new_record?
      key = OpenSSL::PKey::EC.new curve_name
      key.generate_key
      self.body = key.to_der
    end
  end

  def update_fingerprint
    self.fingerprint = fingerprint_hash_algorithm.hexdigest(to_openssl.public_key.to_bn.to_s)
  end
end
