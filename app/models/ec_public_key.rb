class ECPublicKey < PublicKey
  validates :curve_name, presence: true

  def ec?
    true
  end

  def import_from_r509(r509)
    super
    i = r509.signature_algorithm.rindex('-')
    self.hash_algorithm = r509.signature_algorithm[i + 1, r509.signature_algorithm.length - i].downcase
    self.curve_name = r509.curve_name
  end
end