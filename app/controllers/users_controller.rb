class UsersController < ApplicationController
  helper_method :validates?
  def index
    @users = User.all
  end

  def new
    @validations = flash[:validations]
    data = flash.try(:[], :data)
    @user = if data
      User.create data
    else
      User.new
    end
  end

  def create
    user = User.create user_params
    user.randomize_password
    user.create_confirm_token
    if user.invalid?
      logger.info "Failed to save record #{user_params}. Validations failed #{user.errors.inspect}"
      flash[:validations] = user.errors
      flash[:data] = user
      redirect_to action: :new
      return
    end
    begin
      user.save!
    rescue ActiveRecord::RecordInvalid => err
      logger.info "Failed to save record #{user_params} #{err}}"
      flash[:error] = err.to_s
      redirect_to action: :new
    else
      UserMailer.new_account(user).deliver_now
      redirect_to user
    end
  end

  def show
    user_id = params[:id] || session[:user_id]
    @user = User.find(user_id)
  end

  def user_params
    params[:user].permit(:first_name, :last_name, :email)
  end

  protected
  def validates?(selector, if_true)
    if_true if @validations
      .try(:[], selector.to_s)
      .try(:any?)
  end
end
