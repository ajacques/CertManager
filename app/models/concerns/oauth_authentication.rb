module OauthAuthentication
  extend ActiveSupport::Concern

  module ClassMethods
    def authenticate_with_github_user(user)
      User.find_by('email = ? OR github_username = ?', user['email'], user['login'])
    end

    def fetch_access_token(settings, redirect_to, code, state)
      props = {
        client_id: settings.client_id,
        client_secret: settings.client_secret,
        code: code,
        redirect_to: redirect_to,
        state: state
      }
      result = RestClient.post('https://github.com/login/oauth/access_token', props, accept: :json)
      JSON.parse(result)
    end
  end
end
