class PrivateKey < ActiveRecord::Base
  has_one :certificate
  validates :key_type, inclusion: { in: %W(rsa ec), message: '%{value} must be a supported key type' }
  validates :bit_length, numericality: { only_integer: true, greater_than_or_equal_to: 512 }, if: :rsa?
  validates :curve_name, presence: true, if: :ec?
  validates :curve_name, absence: true, if: 'not ec?'
  after_initialize :generate_key

  def rsa?
    key_type == 'rsa'
  end
  def ec?
    key_type == 'ec'
  end
  def to_pem
    to_openssl.to_pem
  end
  def to_der
    self.body
  end
  def to_text
    to_openssl.to_text
  end
  def to_openssl
    return OpenSSL::PKey::RSA.new body if rsa?
    return OpenSSL::PKey::EC.new body if ec?
  end
  def to_h
    key_attribs
  end
  def as_json(opts=nil)
    to_h.as_json(opts)
  end

  private
  def generate_key
    if valid? and new_record?
      key = R509::PrivateKey.new key_attribs
      self.body = key.to_der
      self.fingerprint = Digest::SHA1.hexdigest(public_param(key))
    end
  end
  def public_param(key)
    return key.key.params['n'].to_s if rsa?
    return key.key.public_key.to_bn.to_s if ec?
  end
  def key_attribs
    self.slice(:bit_length, :curve_name).merge(type: self.key_type)
  end
end
