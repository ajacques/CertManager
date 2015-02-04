class PublicKey < ActiveRecord::Base
  has_one :certificate
  belongs_to :subject, autosave: true
  has_many :revocation_endpoints, autosave: true

  def method_missing(meth, *args, &blk)
    return nil if self.body.nil?
    cert = R509::Cert.new cert: self.body
    cert.send(meth, *args)
  end

  def self.from_r509(crt)
    pub = PublicKey.new
    pub.body = crt.to_pem
    pub.subject = Subject.from_r509(crt.subject)
    pub.not_before = crt.not_before
    pub.not_after = crt.not_after
    crt.crl_distribution_points.uris.each do |uri|
      pub.revocation_endpoints << RevocationEndpoint.new(uri_type: 'crl', endpoint: uri)
    end if crt.crl_distribution_points.present?
    pub.modulus_hash = Digest::SHA1.hexdigest(crt.public_key.n.to_s)
    pub
  end
end
