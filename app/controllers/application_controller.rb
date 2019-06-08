class ApplicationController < ActionController::Base
  attr_accessor :model_id
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login
  append_before_action :initialize_user
  helper_method :user_signed_in?
  helper_method :current_user
  helper_method :model_id
  helper_method :page_title
  include RequestLogging

  def self.public_endpoint
    skip_before_action :require_login
  end

  def page_title(title = nil)
    if title
      @title = title
    elsif @title
      "#{@title} | #{t 'brand'}"
    else
      t 'brand'
    end
  end

  protected

  attr_reader :current_user

  def initialize_user
    return unless session.key? :user_id

    @current_user = User.find session[:user_id]
    Raven.user_context id: current_user.id
    RequestStore.store[:actor] = @current_user
  rescue ActiveRecord::RecordNotFound
    @current_user = nil
  end

  def require_login
    unless user_signed_in?
      session[:return_url] = request.fullpath
      redirect_to new_user_session_path
    end
  end

  def user_signed_in?
    session.key?(:user_id)
  end
end
