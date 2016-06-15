class OAuthProvider < ActiveRecord::Base
  validates :name, :requested_scopes, :authorize_uri_base, :token_uri_base, :client_id, :client_secret, presence: true

  def self.github
    find_by_name('github')
  end

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
    token_info = JSON.parse(RestClient.post(token_uri_base, props, accept: :json))
    access_token = token_info['access_token']

    raise 'Need access to user email scope' unless token_info['scope'].split(',').include?('user:email')

    access_token
  end

  def fetch_orgs(user)
    headers = {
      authorization: "token #{user.github_access_token}"
    }
    user_info = JSON.parse(RestClient.get('https://api.github.com/user/orgs', headers))
    Hash[user_info.map do |org|
      [org['id'], org['login']]
    end]
  end

  def login(params)
    access_token = params[:access_token]
    user_info = JSON.parse(RestClient.get('https://api.github.com/user?access_token=' + access_token, accept: :json))
    user = User.authenticate_with_github_user(user_info)

    user ||= register_account(user_info, access_token)
    user.github_access_token = access_token
    user.save!
    user
  end

  private

  def register_account(user_info, access_token)
    # TODO: This won't split all names correctly.
    name_split_attempt = user_info['name'].split(' ')
    user_props = {
      first_name: name_split_attempt[0],
      last_name: name_split_attempt[1],
      email: user_info['email'],
      github_access_token: access_token,
      github_username: user_info['login'],
      can_login: true
    }
    user = User.new user_props
    user.randomize_password
    user
  end
end
