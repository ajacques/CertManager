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

    certificates.each do |cert|
      next unless cert.public_key_id || cert.issuer_id
      pub_key = PublicKey.find_by(subject_id: cert.public_key.issuer_subject_id)
      cert.issuer = Certificate.find_by(public_key: pub_key)
      cert.save!
    end
  end

  def save
    ActiveRecord::Base.transaction do
      (public_keys + private_keys).each(&:save!)
    end
  end

  def promote_all_to_certificates
    certs = []
    public_keys.each do |pub|
      cert = Certificate.for_public_key(pub).first
      next unless cert
      cert.public_key = pub
      cert.save!
      certs << cert
    end
    certs
  end

  def self.from_string(string)
    # TODO: Better parser. This is a regular language
    parts = []
    part = ''
    string.lines.each do |line|
      part += line
      if line.starts_with?('-----END')
        parts.push(part) if line.include?(marker)
        part = ''
      end
    end
    parts
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
