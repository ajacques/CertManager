class ValidateCertificateJob < ActiveJob::Base
  queue_as :refresh

  def perform
    Certificate.joins(public_key: [:revocation_endpoints])
  end
end