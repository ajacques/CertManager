class RSAPrivateKey < PrivateKey
  validates :bit_length, numericality: { only_integer: true, greater_than_or_equal_to: 512 }
  after_initialize :generate_key

  def rsa?
    true
  end

  def to_openssl
    OpenSSL::PKey::RSA.new body
  end

  def to_pem
    "-----BEGIN RSA PRIVATE KEY-----\n#{Base64.encode64(body)}-----END RSA PRIVATE KEY-----"
  end

  def create_public_key
    key = RSAPublicKey.new slice(:bit_length)
    key.private_key = self
    key
  end

  def self.import(src)
    find_or_initialize_by(body: src.to_der) do |r|
      r.bit_length = src.bit_length
      r.body = src.to_der
    end
  end

  private

  def generate_key
    return unless valid?
    if body
      key = R509::PrivateKey.new key: to_openssl
    else
      key = R509::PrivateKey.new slice(:bit_length)
      self.body = key.to_der
    end
    self.fingerprint = fingerprint_hash_algorithm.hexdigest(key.key.params['n'].to_s)
  end
end
