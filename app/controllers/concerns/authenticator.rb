module Authenticator
  extend ActiveSupport::Concern

  protected

  def assume_user(user)
    user.sign_in_count += 1
    user.last_sign_in_at = Time.now
    user.save!

    reset_session
    session[:user_id] = user.id
  end
end
