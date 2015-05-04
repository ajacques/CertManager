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

  test 'can import ec ca' do
    pem = get_example_cert :ec_ca
    pub = PublicKey.from_pem pem
    assert_not_nil pub

    assert pub.ec?
    assert_equal 'secp384r1', pub.curve_name
    assert_nil pub.bit_length
    assert pub.is_ca?
    assert pub.valid?, pub.errors
    assert_equal 'sha384', pub.hash_algorithm
  end

  test 'has san' do
    san = %w(example.com www.example.com)
    pub = RSAPublicKey.new subject_alternate_names: san
    assert_equal san, pub.subject_alternate_names
  end
end