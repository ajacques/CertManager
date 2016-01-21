class PrivateKey < ActiveRecord::Base
  has_one :certificate
  after_initialize :generate_key

  def rsa?
    false
  end

  def ec?
    false
  end

  def to_der
    body
  end

  delegate :to_text, to: :to_openssl

  def to_h
    key_attribs
  end

  def as_json(opts = nil)
    to_h.as_json(opts)
  end

  def self.import(pem)
    ossl = R509::PrivateKey.new key: pem
    RSAPrivateKey.import ossl if ossl.rsa?
  end

  private

  def key_attribs
    slice(:bit_length, :curve_name).merge(type: type)
  end
end
