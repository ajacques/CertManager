class CsrSan < ActiveRecord::Base
  belongs_to :certificate_sign_request
  belongs_to :subject_alternate_name
end
