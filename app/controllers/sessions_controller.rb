class SessionsController < ApplicationController
  public_endpoint

  def new
    redirect_to root_path if current_user
    @error_message = flash[:error]
    @username = flash[:username]
    redirect_to install_user_path unless User.any? || OAuthProvider.any?
  end

  def create
    email = params[:email]
    user = User.authenticate!(email, params[:password])
    unless user
      logger.info "#{email} did not match any known users"
      flash[:username] = email
      flash[:error] = :no_match
      redirect_to action: :new
      return
    end

    url = session[:return_url] || root_path
    assume_user(user)
    redirect_to url
  end

  def github
    provider = OAuthProvider.find_by_name(:github)
    state = secure_token
    session[:oauth_state] = state

    redirect_to provider.authorize_uri(state)
  end

  def github_finalize
    raise 'Failed to verify security token' unless session[:oauth_state] == params[:state]
    provider = OAuthProvider.find_by_name(:github)
    access_token = provider.fetch_token params.permit(:code, :state)

    session.destroy
    reset_session
    session[:access_token] = access_token
    redirect_to action: :github_authenticate
  end

  def github_authenticate
    raise 'Need access token' unless session.key? :access_token
    access_token = session[:access_token]
    provider = OAuthProvider.find_by_name(:github)
    user = provider.login access_token: access_token

    assume_user user
    redirect_to root_path
  end

  def destroy
    session.destroy
    reset_session
    redirect_to new_user_session_path
  end

  private

  def assume_user(user)
    reset_session
    session[:user_id] = user.id
  end

  def secure_token
    SecureRandom.hex
  end
end
