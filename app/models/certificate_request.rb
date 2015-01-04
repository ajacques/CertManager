class CertificateRequest < ActiveRecord::Base
  def self.from_subject(subject)
    
  end
  def self.from_r509(orig)
    csr = CertificateRequest.new
    csr.subject = orig.subject.to_s
    csr.body = orig.to_pem
    csr.key = orig.key.to_pem
    csr
  end
end