require 'securerandom'

class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
  end

  def create
    user = User.create user_params
    user.password = SecureRandom.urlsafe_base64
    user.create_confirm_token
    user.save!
    UserMailer.new_account(user).deliver_later
    redirect_to user
  end

  def show
    user_id = params[:id] || session[:user_id]
    @user = User.find(user_id)
  end

  def user_params
    params[:user].permit(:first_name, :last_name, :email)
  end
end
