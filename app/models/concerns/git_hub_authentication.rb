module GitHubAuthentication
  extend ActiveSupport::Concern

  module ClassMethods
    def auth_with_github_code(code)
      token_info = fetch_access_token(code)
    end

    def authenticate_with_github_user(user)
      user = User.where('email = ? OR github_username = ?', user['email'], user['login']).first
    end

    def fetch_access_token(client_id, redirect_to, code)
      uri = URI.parse('https://github.com/login/oauth/access_token')
      props = {
        client_id: client_id,
        client_secret: secret,
        code: params[:code],
        redirect_to: redirect_to,
        state: params[:state]
      }
      result = RestClient.post('https://github.com/login/oauth/access_token', props, {accept: :json})
      JSON.parse(result)
    end
  end
end
