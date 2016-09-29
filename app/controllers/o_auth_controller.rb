class OAuthController < ApplicationController
  include Authenticator
  public_endpoint

  def begin
    provider = OAuthProvider.find_by_name(params[:provider])
    session[:oauth_state] = state = secure_token

    redirect_to provider.authorize_uri(state)
  end

  def receive
    raise 'Failed to verify security token' unless session[:oauth_state] == params[:state]
    provider = OAuthProvider.find_by_name(params[:provider])
    raise 'Invalid OAuth provider' unless provider
    access_token = provider.fetch_token params.permit(:code, :state)

    session.destroy
    reset_session
    session[:access_token] = access_token
    redirect_to oauth_authenticate_path
  end

  def authenticate
    unless session.key? :access_token
      respond_to do |format|
        format.html {
          flash[:error] = :missing_token
          redirect_to new_user_session_path
        }
        format.all {
          render status: :bad_request, nothing: true
        }
      end
      return
    end
    access_token = session[:access_token]
    provider = OAuthProvider.find_by_name(params[:provider])
    user = provider.login access_token: access_token

    assume_user user
    redirect_to root_path
  rescue NotAuthorized
    Raven.breadcrumbs.record do |crumb|
      crumb.level = :warn
      crumb.message = 'Login attempt rejected. Not authorized'
    end
    flash[:error] = :not_authorized
    redirect_to new_user_session_path
  end

  private

  def secure_token
    SecureRandom.hex
  end
end
