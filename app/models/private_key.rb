class PrivateKey < ActiveRecord::Base
  has_one :certificate
  after_initialize :generate_key

  def rsa?
    false
  end
  def ec?
    false
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
  def to_h
    key_attribs
  end
  def as_json(opts=nil)
    to_h.as_json(opts)
  end

  def self.import(pem)
    ossl = R509::PrivateKey.new key: pem
    if ossl.rsa?
      RSAPrivateKey.import ossl
    end
  end

  private
  def key_attribs
    self.slice(:bit_length, :curve_name).merge(type: self.key_type)
  end
end
