class PublicKey < ActiveRecord::Base
  has_one :certificate

  def self.from_r509(crt)
    pub = PublicKey.new
    pub.body = crt.to_pem
    pub.subject = crt.subject.to_s
    pub.common_name = crt.subject.CN
    pub.not_before = crt.not_before
    pub.not_after = crt.not_after
    pub.modulus_hash = Digest::SHA1.hexdigest(crt.public_key.n.to_s)
    pub
  end
end
