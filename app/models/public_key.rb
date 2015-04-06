class PublicKey < ActiveRecord::Base
  has_one :certificate
  belongs_to :subject, autosave: true
  has_many :revocation_endpoints, autosave: true

  def method_missing(meth, *args, &blk)
    return nil if self.body.nil?
    cert = R509::Cert.new cert: self.body
    cert.send(meth, *args)
  end
  def to_pem
    self.body
  end

  def self.from_r509(crt)
    PublicKey.find_or_initialize_by(body: crt.to_pem) do |r|
      r.subject = Subject.from_r509(crt.subject)
      r.not_before = crt.not_before
      r.not_after = crt.not_after
      crt.crl_distribution_points.uris.each do |uri|
        r.revocation_endpoints << RevocationEndpoint.find_or_initialize_by(uri_type: 'crl', endpoint: uri)
      end if crt.crl_distribution_points.present?
      r.modulus_hash = crt.fingerprint
    end
  end
end
