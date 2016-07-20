class UserMailer < BaseMailer
  def validate_mail_server(user)
    headers 'X-Notify-Type' => 'Account-Test'
    @user = user
    subject = t 'account.mailers.test_mail_serve'

    mail to: user.email_addr, subject: subject, &:text
  end
end
