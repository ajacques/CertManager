class ImportSet
  attr_reader :public_keys, :private_keys

  def initialize(certificates: [], private_keys: [])
    @src_certificates = certificates
    @src_private_keys = private_keys

    @public_keys = []
    @private_keys = []
  end

  def import
    ## Graph modification logic
    ## First create nodes
    @src_certificates.each do |cert|
      public_keys << PublicKey.import(cert)
    end
    @src_private_keys.each do |key|
      private_keys < PrivateKey.import(key)
    end

    ## Then add/update edges
    # Link public keys to appropriate private keys
    public_keys.each do |pub|
      pub.private_key = PrivateKey.find_by(fingerprint: pub.fingerprint)
    end
  end

  def promote_all_to_certificates
    public_keys.each do |pub|
      cert = Certificate.for_public_key(pub).first
      next unless cert
      cert.public_key = pub
      cert.save!
    end
  end

  def self.from_array(array)
    certs = []
    privates = []
    array.each do |item|
      certs << item if item.is_a?(OpenSSL::X509::Certificate)
    end
    ImportSet.new certificates: certs, private_keys: privates
  end
end
