class RSAPublicKey < PublicKey
  validates :bit_length, numericality: { only_integer: true, greater_than: 0 }

  def rsa?
    true
  end

  def to_h
    hash = super
    hash[:bit_length] = bit_length
    hash
  end

  def import_from_r509(r509)
    super
    self.bit_length = r509.bit_length
    self.hash_algorithm = r509.signature_algorithm[0, r509.signature_algorithm.index('With')]
  end

  protected

  def update_fingerprint
    raw = OpenSSL::X509::Certificate.new(to_der).public_key.params['n'].to_i.to_s
    self.fingerprint = Digest::SHA256.hexdigest raw
  end
end
