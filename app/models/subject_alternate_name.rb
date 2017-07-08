class SubjectAlternateName < ApplicationRecord
  belongs_to :public_key
  belongs_to :csr, class_name: 'CertificateSignRequest::CsrSan'
end
