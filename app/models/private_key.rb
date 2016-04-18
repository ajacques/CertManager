class PrivateKey < ActiveRecord::Base
  has_one :certificate
  has_many :public_keys_by_fingerprint, -> { readonly }, foreign_key: :fingerprint, primary_key: :fingerprint
  has_many :public_keys
  has_many :certificate_sign_requests

  def self.with_subjects
    keys = Arel::Table.new :private_keys
    pubs = Arel::Table.new :public_keys
    csrs = Arel::Table.new :certificate_sign_requests
    subjects = Arel::Table.new :subjects
    pub_sub =
      keys.outer_join(pubs).on(keys[:id].eq(pubs[:private_key_id]))
          .join(subjects).on(pubs[:subject_id].eq(subjects[:id]))
          .project(keys[:id], subjects[:CN])
    csr_sub =
      keys.outer_join(csrs).on(keys[:id].eq(csrs[:private_key_id]))
          .join(subjects).on(csrs[:subject_id].eq(subjects[:id]))
          .project(keys[:id], subjects[:CN])
    query = pub_sub.union(csr_sub)
    find_by_sql(query.to_sql)
  end

  def rsa?
    false
  end

  def ec?
    false
  end

  def to_der
    body
  end

  delegate :sign, to: :to_openssl
  delegate :public_key, to: :to_openssl
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

  protected

  def fingerprint_hash_algorithm
    Digest::SHA256
  end

  private

  def key_attribs
    slice(:bit_length, :curve_name).merge(type: type)
  end
end
