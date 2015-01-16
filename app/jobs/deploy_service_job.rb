require 'net/http'

class DeployServiceJob < ActiveJob::Base
  queue_as :deployment

  around_perform do |job, block|
    # Not thread safe
    plogger = Rails.logger
    Rails.logger
    block.call
    Rails.logger = plogger
  end

  def perform(service)
    service.deploy
  end
end