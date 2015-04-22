require 'test_helper'

class PublicKeyTest < ActiveSupport::TestCase
  test 'ca cert' do
    pub = public_key(:rsa_ca)
    assert pub.is_ca?
    ossl = pub.to_openssl
    assert ossl.version == 2
    r509 = R509::Cert.new cert: ossl
    assert r509.basic_constraints.is_ca?
  end
end