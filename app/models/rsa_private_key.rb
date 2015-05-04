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

  private
  def generate_key
    if valid? and new_record?
      key = R509::PrivateKey.new self.slice(:bit_length)
      self.body = key.to_der
      self.fingerprint = Digest::SHA1.hexdigest(key.key.params['n'].to_s)
    end
  end
end