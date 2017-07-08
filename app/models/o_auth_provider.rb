class OAuthProvider < ApplicationRecord
  has_many :authorizations
  validates :name, :requested_scopes, :authorize_uri_base, :token_uri_base, :client_id, :client_secret, presence: true

  def self.github
    find_by(name: 'github')
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

  def base_domain
    URI(authorize_uri_base).host
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

  def fetch_orgs(token)
    user_info = api_get('/user/orgs', token)
    Hash[user_info.map do |org|
      [org['id'], org['login']]
    end]
  end

  def login(params)
    access_token = params[:access_token]
    Raven.breadcrumbs.record do |crumb|
      crumb.category = 'auth.oauth'
      crumb.message = 'Fetching OAuth user info'
    end
    user_info = api_get('/user', access_token)
    org_info = fetch_orgs(access_token)
    # Default Permit All. This will enable users to login and add permissions
    if authorizations.any?
      auths = authorizations.for_oauth_attempt(user_info['id'], org_info.keys)
      final_auth_vector = auths.first
      raise NotAuthorized unless final_auth_vector
      Raven.breadcrumbs.record do |crumb|
        crumb.data = {
          vectors: auths.map(&:to_s)
        }
        crumb.category = 'auth.oauth'
        crumb.message = "Authorized through #{final_auth_vector}"
      end
    end
    user = User.authenticate_with_github_user(user_info)

    user ||= register_account(user_info)
    refresh_account(user, user_info, access_token)
    user
  end

  def authorization_from_identifier(identifier, user)
    resp = api_get("/search/users?q=#{identifier}", user.github_access_token)
    raise 'Failed to fetch any matching values' if resp.key? 'errors'
    return nil unless resp.key? 'items'
    auth = resp['items'].first
    image = URI(auth['avatar_url'])
    type = if auth['type'] == 'Organization'
             'group'
           elsif auth['type'] == 'User'
             'user'
           else
             raise "Unknown ACL actor type: #{auth['type']}, name: #{auth['login']}"
           end
    props = {
      identifier: auth['id'],
      authorization_type: type,
      display_name: auth['login'],
      o_auth_provider: self,
      display_image: image,
      display_image_host: image.host,
      url: auth['html_url']
    }
    Authorization.new(props)
  end

  private

  def api_get(url, token)
    full_url = "https://api.github.com#{url}"
    Raven.breadcrumbs.record do |crumb|
      crumb.category = 'auth.oauth'
      crumb.message = "OAuth API call: #{full_url}"
    end
    resp = Faraday.get full_url, {}, 'Authorization' => "token #{token}", 'Accept' => 'application/vnd.github.v3+json'
    JSON.parse(resp.body)
  end

  def register_account(user_info)
    user = User.new can_login: true, github_userid: user_info['id']
    user.randomize_password
    user
  end

  def refresh_account(user, user_info, access_token)
    email_result = api_get('/user/emails', access_token)
    email_result = email_result.select do |email|
      email['primary'] && email['verified']
    end
    email = email_result.first['email']

    # TODO: This won't split all names correctly.
    name_split_attempt = user_info['name'].split(' ')
    user_props = {
      first_name: name_split_attempt[0],
      last_name: name_split_attempt[1],
      email: email,
      github_access_token: access_token,
      github_username: user_info['login']
    }
    user.update_attributes user_props
  end
end
