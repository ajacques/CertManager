class CertificateMailer < ActionMailer::Base
	def expiration_notice(email, cert_list)
		@certificates = cert_list
		headers 'Importance' => 'High',
      'X-Notify-Type' => 'Certificate-Expiration',
      'X-Priority' => '1'

		mail to: email, subject: 'Certificate Expiration Notice' do |format|
			format.text
		end
	end
end