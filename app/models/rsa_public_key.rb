class RSAPublicKey < PublicKey
  validates :bit_length, numericality: { only_integer: true, greater_than: 0 }

  def rsa?
    true
  end

  def import_from_r509(r509)
    super
    self.bit_length = r509.bit_length
    self.hash_algorithm = r509.signature_algorithm[0, r509.signature_algorithm.index('With')]
  end
end