require 'net/http'

class DeployCertificateJob < ApplicationJob
  queue_as :deployment

  def perform(cert)
    cert.services.each(&:deploy)
  end
end
