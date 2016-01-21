class InstallController < ApplicationController
  skip_before_action :require_login
  def user
    redirect_to root_path if User.any?
  end

  def create_user
    redirect_to root_path if User.any?
    reset_session
    params = user_params
    params[:can_login] = true
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
