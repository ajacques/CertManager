class RSAPublicKey < PublicKey
  validates :bit_length, numericality: { only_integer: true, greater_than: 0 }
  before_save :compute_fingerprint

  def rsa?
    true
  end

  def to_h
    h = super
    h[:bit_length] = bit_length
    h
  end

  def import_from_r509(r509)
    super
    self.bit_length = r509.bit_length
    self.hash_algorithm = r509.signature_algorithm[0, r509.signature_algorithm.index('With')]
  end

  private
  def compute_fingerprint
    unless fingerprint
      raw = OpenSSL::X509::Certificate.new(to_der).public_key.params['n'].to_i.to_s
      self.fingerprint = Digest::SHA256.hexdigest raw
    end
  end
end