class InstallController < ApplicationController
  def user
    if User.any?
      redirect_to root_path
    end
  end

  def create_user
    reset_session
    params = user_params.merge ({
      can_login: true
    })
    user = User.create params
    logger.info params
    user.save!
    @user = user.id
    redirect_to install_configure_path
  end

  protected
  def require_login?
    false
  end

  private
  def user_params
    params.permit(:email, :password, :first_name, :last_name)
  end
end