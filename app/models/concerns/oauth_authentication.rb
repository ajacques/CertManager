module OauthAuthentication
  extend ActiveSupport::Concern

  def oauth_organizations
    cached(key: 'oauth_organizations', ttl: 5.minutes) do
      OAuthProvider.github.fetch_orgs(self)
    end
  end

  module ClassMethods
    def authenticate_with_github_user(user)
      User.find_by('email = ? OR github_username = ?', user['email'], user['login'])
    end
  end

  private

  # TODO: Move this out of here
  def cached(key:, ttl: 5.minutes, &block)
    redis = CertManager::Configuration.redis_client
    redis_key = "User_#{id}_#{key}"
    value = redis.get(redis_key)
    value = JSON.parse(value) if value
    unless value
      value = yield
      redis.setex(redis_key, ttl, value.to_json)
    end
    value
  end
end
