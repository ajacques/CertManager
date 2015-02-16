class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login

  protected
  def require_login
    if require_login? and not user_signed_in?
      session[:return_url] = request.fullpath
      redirect_to new_user_session_path
    end
  end
  def user_signed_in?
    session.has_key?(:user_id)
  end
  def require_login?
    true
  end
end
