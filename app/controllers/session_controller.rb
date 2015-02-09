class SessionController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:email_address], params[:password])
    redirect_to login_path if user.nil?

    url = session[:return_url] || root_path
    reset_session
    session[:user_id] = user.id
    redirect_to url
  end

  def destroy
    reset_session
    redirect_to login_path
  end

  protected
  def require_login?
    false
  end
end