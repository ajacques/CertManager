require 'net/http'

class DeployCertificateJob < ActiveJob::Base
  queue_as :deployment

  def perform(cert)
    cert.services.each do |service|
      service.deploy
    end
  end
end