class InstallController < ApplicationController
  skip_before_filter :require_login
  def user
    if User.any?
      redirect_to root_path
    end
  end

  def create_user
    if User.any?
      redirect_to root_path
    end
    reset_session
    params = user_params.merge ({
      can_login: true
    })
    user = User.create! params
    logger.info params
    @user = user.id
    redirect_to install_configure_path
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :first_name, :last_name)
  end
end