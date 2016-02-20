class SessionsController < ApplicationController
  include Authenticator
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

  def destroy
    session.destroy
    reset_session
    redirect_to new_user_session_path
  end
end
