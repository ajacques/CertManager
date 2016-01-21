require 'net/http'

class DeployCertificateJob < ActiveJob::Base
  queue_as :deployment

  def perform(cert)
    cert.services.each(&:deploy)
  end
end
