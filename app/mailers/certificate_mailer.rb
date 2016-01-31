class CertificateMailer < BaseMailer
  def expiration_notice(user, cert_list)
    @certificates = cert_list
    @user = user
    headers 'Importance' => 'High',
            'X-Notify-Type' => 'Certificate-Expiration',
            'X-Priority' => '1'

    mail to: user.email_addr, subject: 'Certificate Expiration Notice' do |format|
      format.html do
        render layout: 'mailers/single_column'
      end
      format.text
    end
  end
end
