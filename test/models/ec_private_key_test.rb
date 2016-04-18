require 'test_helper'

class ECPrivateKeyTest < ActiveSupport::TestCase
  test 'generates ec' do
    key = ECPrivateKey.new curve_name: 'secp384r1'
    assert key.ec?
    assert_not_nil key.to_openssl
    assert_not_nil key.to_pem
    assert key.valid?
  end
  test 'has public key' do
    key = ECPrivateKey.new curve_name: 'secp384r1'
    key.public_key
  end
end