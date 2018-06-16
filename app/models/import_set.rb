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
      private_keys << PrivateKey.import(key)
    end

    ## Then add/update edges
    # Link public keys to appropriate private keys
    public_keys.each do |pub|
      pub.private_key = PrivateKey.find_by(fingerprint: pub.fingerprint)
    end
  end

  def save
    ActiveRecord::Base.transaction do
      (public_keys + private_keys).each(&:save!)
    end
  end

  def promote_all_to_certificates(user_identity)
    certs = []
    public_keys.each do |pub|
      cert = Certificate.for_public_key(pub).first
      cert ||= promote_pub_to_cert pub, user_identity
      cert.public_key = pub
      cert.save!
      certs << cert
    end
    private_keys.each do |priv|
      cert = Certificate.for_private_key(priv).first
      next unless cert # Don't create any orphaned private keys
      cert.private_key = priv
      cert.save!
      certs << cert
    end
    # Configure issuers
    certs.each do |cert|
      pub_key = PublicKey.find_by(subject_id: cert.public_key.issuer_subject_id)
      cert.issuer = Certificate.find_by(public_key: pub_key) if pub_key
      cert.save!
    end
    certs
  end

  def self.from_array(array)
    certs = []
    privates = []
    array.each do |item|
      certs << item if item.is_a? OpenSSL::X509::Certificate
      next unless item.is_a? String
      matches = /^-{5}BEGIN ([A-Z ]+)-{5}/.match(item)
      case matches[1]
      when 'RSA PRIVATE KEY'
        privates << item
      when 'CERTIFICATE'
        certs << item
      else
        raise Error, "Unknown type #{matches[1]}"
      end
    end
    ImportSet.new certificates: certs, private_keys: privates
  end

  private

  def promote_pub_to_cert(pub_key, user_identity)
    private_key = PrivateKey.find_by(fingerprint: pub_key.fingerprint)
    Certificate.new public_key: pub_key, private_key: private_key, created_by: user_identity, updated_by: user_identity
  end
end
