class UserMailerPreview < ActionMailer::Preview
  def new_account
    UserMailer.new_account User.first
  end
  def recover_account
    UserMailer.recover_account User.first, '12.34.56.78'
  end
end