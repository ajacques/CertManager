class ECPublicKey < PublicKey
  validates :curve_name, presence: true

  def ec?
    true
  end

  def import_from_r509(r509)
    super
    algo = r509.signature_algorithm
    i = algo.rindex('-')
    self.hash_algorithm = if i
                            algo[i + 1, algo.length - i].downcase
                          else
                            algo[0, algo.index('With')]
                          end
    self.curve_name = r509.curve_name
  end

  protected

  def update_fingerprint
    self.fingerprint = fingerprint_hash_algorithm.hexdigest(to_openssl.public_key.public_key.to_bn.to_s)
  end
end
