class CertificateMailerPreview < ActionMailer::Preview
  def expiration_notice
    CertificateMailer.expiration_notice User.first, Certificate.all
  end
end