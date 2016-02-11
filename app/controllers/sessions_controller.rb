class SessionsController < ApplicationController
  skip_before_action :require_login

  def new
    redirect_to root_path if current_user
    @error_message = flash[:error]
    @username = flash[:username]
    redirect_to install_user_path unless User.any?
  end

  def create
    user = User.authenticate!(params[:email], params[:password])
    unless user
      logger.info "#{params[:email]} did not match any known users"
      flash[:username] = params[:email]
      flash[:error] = :no_match
      redirect_to action: :new
      return
    end

    url = session[:return_url] || root_path
    assume_user(user)
    redirect_to url
  end

  def github
    client_id = Settings::GitHubAuth.new.client_id
    state = secure_token
    session[:github_auth_token] = state
    redirect_to github_authorize_url(client_id, state)
  end

  def github_finalize
    raise 'Failed to verify security token' unless session[:github_auth_token] == params[:state]
    settings = Settings::GitHubAuth.new
    client_id = settings.client_id
    secret = settings.client_secret

    token_info = User.fetch_access_token(client_id, root_path, params[:code])
    access_token = token_info['access_token']

    raise 'Need access to user email scope' unless body['scope'].split(',').include?(user:email)

    user_info = JSON.parse(RestClient.get('https://github.com/user?access_token=' + access_token, {accept: :json}))
    user = User.authenticate_with_github_user(user_info)

    render plain: body.inspect
  end

  def destroy
    reset_session
    redirect_to new_user_session_path
  end

  private

  def github_authorize_url(client_id, state)
    url = URI('https://github.com/login/oauth/authorize')
    url.query = {
      client_id: client_id,
      scope: 'user:email,read:org',
      state: state
    }.to_query
    url.to_s
  end

  def assume_user(user)
    reset_session
    session[:user_id] = user.id
  end

  def secure_token
    SecureRandom.hex
  end
end
