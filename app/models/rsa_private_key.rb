class RSAPrivateKey < PrivateKey
  validates :bit_length, numericality: { only_integer: true, greater_than_or_equal_to: 512 }

  def rsa?
    true
  end
  def to_openssl
    OpenSSL::PKey::RSA.new body
  end
  def create_public_key
    key = RSAPublicKey.new self.slice(:bit_length)
    key.private_key = self
    key
  end
  def self.import(src)
    self.find_or_initialize_by(body: src.to_der) do |r|
      r.bit_length = src.bit_length
      r.body = src.to_der
    end
  end

  private
  def generate_key
    if valid? and self.body.nil?
      key = R509::PrivateKey.new self.slice(:bit_length)
      self.body = key.to_der
      self.fingerprint = Digest::SHA1.hexdigest(key.key.params['n'].to_s)
    end
  end
end