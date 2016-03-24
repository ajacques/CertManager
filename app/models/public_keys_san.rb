class PublicKeysSan < ActiveRecord::Base
  belongs_to :public_key
  belongs_to :subject_alternate_name
end
