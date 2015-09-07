class UserRecoveryController < ApplicationController
  skip_before_action :require_login
  append_before_action :reject_authenticated

  def send_mail
    user = User.find_by_email params[:email]
    user.create_reset_token
    user.save!
    UserMailer.recover_account(user, request.ip).deliver_now
    redirect_to action: :after_send
  end

  def recover
    user = User.find params[:id]
    # Need to check
    user.update password_params
    user.reset_token :reset_password
    user.updated_at = Time.now
    user.save!
    render text: user.inspect
  end

  def prompt
    @user = User.find params[:id]
    if params.has_key? :disavow
      @user.reset_token :reset_password
      redirect_to action: :after_disavow
    else
      @user.validate_reset_token! params[:token]
    end
  end

  private
  def reject_authenticated
    render text: '', status: :forbidden if user_signed_in?
  end
  def password_params
    params.require(:user).permit(:reset_password_token, :password, :password_confirmation)
  end
end