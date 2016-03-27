require 'test_helper'

class CertificateSignRequestTest < ActiveSupport::TestCase
  test 'can import san' do
    csr = certificate_sign_requests :csr_with_one_san
    assert_equal ['foobar.example'], csr.subject_alternate_names
  end

  test 'can create san' do
    csr = CertificateSignRequest.new
    csr.certificate = certificates :rsa_ca
    csr.subject = subjects :example
    csr.private_key = private_keys :rsa_key
    csr.subject_alternate_names << 'baz.example'
    csr.save!
    assert_equal ['baz.example'], csr.subject_alternate_names
  end
end
