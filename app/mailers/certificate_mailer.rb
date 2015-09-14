class CertificateMailer < BaseMailer
  def expiration_notice(user, cert_list)
    @certificates = cert_list
    headers 'Importance' => 'High',
      'X-Notify-Type' => 'Certificate-Expiration',
      'X-Priority' => '1'

    mail to: user.email_addr, subject: 'Certificate Expiration Notice' do |format|
      format.text
    end
  end
end
