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

  private
  def generate_key
    if valid?
      rsa = R509::PrivateKey.new type: key_type, bit_length: bit_length
      self.pem = rsa.to_pem
      self.thumbprint = Digest::SHA1.hexdigest(rsa.key.params['n'].to_s)
    end
  end
end
