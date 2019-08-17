class User < ApplicationRecord
  include OauthAuthentication
  validates :first_name, presence: true
  validates :email, email: true, uniqueness: true

  TIME_ZONES = ActiveSupport::TimeZone::MAPPING.map do |_key, value|
    [value]
  end

  def to_s
    "#{first_name} #{last_name}"
  end

  def email_addr
    "#{self} <#{email}>"
  end

  # Returns true if this user can perform {action} on {target}
  def can?(_action, _target)
    true
  end
end
