require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  test 'can self sign' do
    ca = certificates(:rsa_ca)
    ca.sign(ca.public_key)
    assert ca.signed?
    assert ca.can_sign?
  end
end
