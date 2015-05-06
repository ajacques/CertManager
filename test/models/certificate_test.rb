require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  test 'can self sign' do
    ca = certificates(:rsa_ca)
    ca.sign(ca)
    assert ca.signed?
    assert ca.can_sign?
  end
  test 'can import' do
    pem = public_key_raw :rsa_ca
    public_key = PublicKey.import pem
    assert_equal 'AddTrust External CA Root', public_key.subject.CN
  end
end
