class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login
  helper_method :current_user

  protected
  def require_login
    if require_login? and not logged_in?
      session[:return_url] = request.fullpath
      redirect_to login_url
    end
  end
  def logged_in?
    session.has_key?(:user_id)
  end
  def require_login?
    true
  end
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
