class SessionsController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]

  def new
    redirect_to root_path if current_user
    @error_message = flash[:error]
    @username = flash[:username]
    unless User.any?
      redirect_to install_user_path
    end
  end

  def create
    unless user = User.authenticate!(params[:email], params[:password])
      logger.info "#{params[:email]} did not match any known users"
      flash[:username] = params[:email]
      flash[:error] = :no_match
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
end