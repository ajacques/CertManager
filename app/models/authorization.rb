class Authorization < ActiveRecord::Base
  belongs_to :o_auth_provider
  validates :type, inclusion: { in: %w(user group) }
end
