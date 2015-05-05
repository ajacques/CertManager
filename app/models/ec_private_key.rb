class ECPrivateKey < PrivateKey
  validates :curve_name, presence: true

  def ec?
    true
  end
  def to_openssl
    OpenSSL::PKey::EC.new body
  end
  def create_public_key
    key = ECPublicKey.new self.slice(:curve_name)
    key.private_key = self
    key
  end

  private
  def generate_key
    if valid? and new_record?
      key = R509::PrivateKey.new self.slice(:bit_length, :curve_name)
      self.body = key.to_der
      self.fingerprint = Digest::SHA1.hexdigest(key.key.public_key.to_bn.to_s)
    end
  end
end