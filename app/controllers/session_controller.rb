class SessionController < ApplicationController
  def new
  end

  def create
    unless user = User.authenticate(params[:email], params[:password])
      logger.info "#{params[:email]} did not match any known users"
      redirect_to action: :new
      return
    end

    url = session[:return_url] || root_path
    reset_session
    session[:user_id] = user.id
    redirect_to url
  end

  def destroy
    reset_session
    redirect_to new_user_session_path
  end

  protected
  def require_login?
    false
  end
end