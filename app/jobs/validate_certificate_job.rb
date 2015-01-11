class ValidateCertificateJob < ActiveJob::Base
  queue_as :refresh

  def perform
    expiring = Certificate.expiring_in(366.days)
    if expiring.any?
      CertificateMailer.expiration_notice('adam@technowizardry.net', expiring).deliver
    end
  end
end