class UserMailer < BaseMailer
  def new_account(user)
    headers 'X-Notify-Type' => 'Account-Create'
    @user = user
    subject = t 'account.mailers.your_new_account'

    mail to: user.email_addr, subject: subject do |format|
      format.text
    end
  end
  def recover_account(user, src_ip)
    headers 'X-Notify-Type' => 'Account-Recover'
    @user = user
    @src_ip = src_ip
    @create_date = Time.now.in_time_zone user.time_zone
    subject = t 'account.mailers.recover_account'

    mail to: user.email_addr, subject: subject do |format|
      format.text
    end
  end
end