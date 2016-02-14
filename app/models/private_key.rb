class PrivateKey < ActiveRecord::Base
  has_one :certificate
  has_many :public_keys, -> { readonly }, foreign_key: :fingerprint, primary_key: :fingerprint
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
  delegate :as_json, to: :to_h

  def to_h
    {
      bit_length: bit_length,
      type: type,
      fingerprint: fingerprint,
      public_keys: public_keys
    }
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
