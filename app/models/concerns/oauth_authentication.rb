module OauthAuthentication
  extend ActiveSupport::Concern

  module ClassMethods
    def authenticate_with_github_user(user)
      User.find_by('email = ? OR github_username = ?', user['email'], user['login'])
    end
  end
end
