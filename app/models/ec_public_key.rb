class ECPublicKey < PublicKey
  validates :curve_name, presence: true

  def ec?
    true
  end

  def import_from_r509(r509)
    super
    algo = r509.signature_algorithm
    i = algo.rindex('-')
    if i
      self.hash_algorithm = algo[i + 1, algo.length - i].downcase
    else
      self.hash_algorithm = algo[0, algo.index('With')]
    end
    self.curve_name = r509.curve_name
  end
end