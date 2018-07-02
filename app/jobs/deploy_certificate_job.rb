require 'net/http'

class DeployCertificateJob < ApplicationJob
  queue_as :deployment

  def perform(cert)
    cert.services.each do |service|
      DeployServiceJob.perform_later service if service.push_deployable?
    end
  end
end
