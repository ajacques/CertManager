require 'test_helper'

class CertificateTest < ActiveSupport::TestCase
  test 'can self sign' do
    ca = certificates(:rsa_ca)
    ca.sign(ca)
    assert ca.signed?
    assert ca.can_sign?
  end
  test 'can import' do
    pem = get_example_cert :root_ca
    public_key = PublicKey.from_pem pem
    assert_equal 'Unit Test CA', public_key.subject.CN
  end
end
