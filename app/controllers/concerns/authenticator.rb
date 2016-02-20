module Authenticator
  extend ActiveSupport::Concern

  protected

  def assume_user(user)
    reset_session
    session[:user_id] = user.id
  end
end
