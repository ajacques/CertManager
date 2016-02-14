class OAuthProvider < ActiveRecord::Base
  def authorize_uri(state)
    url = URI(authorize_uri_base)
    url.query = {
      client_id: client_id,
      scope: requested_scopes,
      state: state
    }.to_query
    url.to_s
  end

  def fetch_token(params)
    props = {
      client_id: client_id,
      client_secret: client_secret,
      code: params[:code],
      state: params[:state]
    }
    token_info = JSON.parse(RestClient.post('https://github.com/login/oauth/access_token', props, accept: :json))
    access_token = token_info['access_token']

    raise 'Need access to user email scope' unless token_info['scope'].split(',').include?('user:email')

    access_token
  end

  def login(params)
    user_info = JSON.parse(RestClient.get('https://api.github.com/user?access_token=' + params[:access_token], accept: :json))
    user = User.authenticate_with_github_user(user_info)

    if user.nil?
      # TODO: This won't split all names correctly.
      name_split_attempt = user_info['name'].split(' ')
      user_props = {
        first_name: name_split_attempt[0],
        last_name: name_split_attempt[1],
        email: user_info['email'],
        github_access_token: params[:access_token],
        github_username: user_info['login'],
        can_login: true
      }
      user = User.new user_props
      user.randomize_password
    end
    user.github_access_token = params[:access_token]
    user.save!
    user
  end
end
