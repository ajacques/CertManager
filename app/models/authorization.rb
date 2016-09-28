class Authorization < ActiveRecord::Base
  belongs_to :o_auth_provider
  validates :authorization_type, inclusion: { in: %w(user group) }

  scope :for_oauth_attempt, lambda { |user_id, group_ids|
    where("(\"authorization_type\" = 'user' AND \"identifier\" = ?) OR (\"authorization_type\" = 'group' AND \"identifier\" IN (?))",
          user_id.to_s, group_ids.map(&:to_s))
      .order(authorization_type: :desc)
  }

  def self.create_with_identifier(params, user)
    provider = OAuthProvider.find(params[:o_auth_provider_id])
    auth = provider.authorization_from_identifier(params[:identifier], user)
    auth.save!
    auth
  end
end
