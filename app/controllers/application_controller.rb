class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  attr_accessor :model_id
  protect_from_forgery with: :exception
  before_action :require_login
  append_before_action :initialize_user
  helper_method :user_signed_in?
  helper_method :current_user
  helper_method :model_id

  protected
  def current_user
    @current_user
  end
  def initialize_user
    @current_user = User.find session[:user_id] if session.has_key? :user_id
  end
  def require_login
    unless user_signed_in?
      session[:return_url] = request.fullpath
      redirect_to new_user_session_path
      return
    end
  end
  def user_signed_in?
    session.has_key?(:user_id)
  end
end
