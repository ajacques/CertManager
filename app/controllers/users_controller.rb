class UsersController < ApplicationController
  def update
    user = User.find params[:id]
    raise NotAuthorized unless current_user.can? :update_user, user
    user.update! user_update_params
    flash[:action] = :activated_account
    redirect_to user
  rescue ActiveRecord::RecordInvalid => e
    flash[:message] = e.to_s
    flash[:errors] = user.errors
    redirect_to flash[:return_url]
  end

  def index
    @users = User.all
    auths = Authorization.all
    @auths = auths.order(:display_name)
    urls = auths.distinct.pluck(:display_image_host)
    append_content_security_policy_directives(img_src: urls)
  end

  def show
    user_id = params[:id] || session[:user_id]
    @user = User.find(user_id)
    flash[:errors].each do |key, error|
      @user.errors.add(key, error)
    end if flash[:errors]
    flash.clear
    flash[:return_url] = url_for
  end

  private

  def user_params
    params[:user].permit(:first_name, :last_name, :email, :time_zone)
  end

  def user_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :time_zone, :confirmation_token_confirmation, :password, :password_confirmation)
  end
end
