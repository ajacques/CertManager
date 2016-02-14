class UsersController < ApplicationController
  helper_method :validates?

  def activate
    @user = User.find params[:id]
    @user.confirmation_token_confirmation = params[:token]
    @message = flash.try(:[], :message)
    @errors = flash.try(:[], :errors)
    flash[:return_url] = url_for
  end

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
    user = User.new user_params
    user.randomize_password
    user.create_confirm_token
    if user.invalid?
      logger.info "Failed to save record #{user_params}. Validations failed #{user.errors.inspect}"
      flash[:validations] = user.errors
      flash[:data] = user.to_h
      redirect_to action: :new
      return
    end
    begin
      user.save!
    rescue ActiveRecord::RecordInvalid => err
      logger.info "Failed to save record #{user_params} #{err}"
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
    flash[:errors].each do |key, error|
      @user.errors.add(key, error)
    end if flash[:errors]
    flash.clear
    flash[:return_url] = url_for
  end

  protected

  def validates?(selector, if_true)
    if_true if @validations
               .try(:[], selector.to_s)
               .try(:any?)
  end

  private

  def user_params
    params[:user].permit(:first_name, :last_name, :email)
  end

  def user_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :confirmation_token_confirmation, :password, :password_confirmation)
  end
end
