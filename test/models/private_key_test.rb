require 'test_helper'

class PrivateKeyTest < ActiveSupport::TestCase
  test 'generates rsa' do
    key = RSAPrivateKey.new bit_length: 2048
    assert key.rsa?
    assert_equal 2048, key.bit_length
    assert_nil key.curve_name
    assert_not_nil key.to_pem
    assert_not_nil key.to_openssl
    assert key.valid?
  end
  test 'generates rsa public key' do
    key = private_keys :rsa_key
    pkey = key.create_public_key
    assert_not_nil pkey
    assert pkey.rsa?
    assert_equal key, pkey.private_key
  end
  test 'imports rsa' do
    der = private_key_raw :rsa_2048
    key = PrivateKey.import der
    assert_not_nil key, 'Imported key model should not be nil'
    assert_instance_of RSAPrivateKey, key
    assert_equal 2048, key.bit_length, 'Incorrect bit length'
    assert_nil key.curve_name
    assert_equal der, key.to_der
    assert key.valid?
  end
  test 'invalid type' do
    assert_raises ActiveRecord::SubclassNotFound do
      PrivateKey.new type: 'foo'
    end
  end
end
