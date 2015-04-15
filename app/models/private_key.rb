class PrivateKey < ActiveRecord::Base
  has_one :certificate
  validates :key_type, inclusion: { in: %W(rsa), message: '%{value} must be a supported key type' }
  validates :bit_length, numericality: { only_integer: true, greater_than: 0 }
  after_initialize :generate_key

  def rsa?
    key_type == 'rsa'
  end
  def to_pem
    self.pem
  end
  def to_openssl
    OpenSSL::PKey::RSA.new to_pem
  end
  def as_json(opts=nil)
    {
     key_type: key_type,
     bit_length: bit_length
    }.as_json(opts)
  end

  private
  def generate_key
    if valid? and new_record? and rsa?
      rsa = R509::PrivateKey.new type: key_type, bit_length: bit_length
      self.pem = rsa.to_pem
      self.fingerprint = Digest::SHA1.hexdigest(rsa.key.params['n'].to_s)
    end
  end
end
