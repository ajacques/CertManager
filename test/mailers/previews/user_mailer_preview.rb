class UserMailerPreview < ActionMailer::Preview
  def validate_mail_server
    user = User.first
    UserMailer.validate_mail_server user
  end
end
