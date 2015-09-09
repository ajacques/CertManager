class UserMailerPreview < ActionMailer::Preview
  def new_account
    user = User.first
    user.create_confirm_token
    UserMailer.new_account user
  end
  def recover_account
    user = User.first
    user.create_reset_token
    UserMailer.recover_account user, '12.34.56.78'
  end
end