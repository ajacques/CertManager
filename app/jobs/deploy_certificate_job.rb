require 'net/http'

class DeployCertificateJob < ApplicationJob
  queue_as :deployment

  def perform(cert)
    cert.services.filter(&:push_deployable?).each do |service|
      DeployServiceJob.perform_later service
    end
  end
end
