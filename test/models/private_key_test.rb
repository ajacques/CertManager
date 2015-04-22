require 'test_helper'

class PrivateKeyTest < ActiveSupport::TestCase
  test 'generates rsa' do
    key = PrivateKey.new key_type: 'rsa', bit_length: 2048
    assert key.rsa?
    assert key.bit_length == 2048
    assert key.curve_name.nil?
    assert key.to_pem.present?
  end
  test 'invalid type' do
    key = PrivateKey.new key_type: 'foo'
    assert key.invalid?
  end
end
