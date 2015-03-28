class UserMailer < BaseMailer
  def new_account(user)
    headers 'X-Notify-Type' => 'Account-Create'
    @user = user
    subject = t 'account.mailers.your_new_account'

    mail to: "#{user} <#{user.email}>", subject: subject do |format|
      format.text
    end
  end
end