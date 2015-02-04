class DeployServiceJob < ActiveJob::Base
  queue_as :deployment

  before_enqueue do |job|
    redis = CertManager::Configuration.redis_client
    redis.set("job_#{job.job_id}_service", job.arguments.first.id)
  end

  around_perform do |job, block|
    redis = CertManager::Configuration.redis_client
    plogger = Rails.logger
    Rails.logger = Logger.new RedisLogger.new job.job_id
    redis.set("job_#{job.job_id}_status", 1)
    block.call
    redis.set("job_#{job.job_id}_status", 3)
    Rails.logger = plogger
  end

  def perform(service)
    service.deploy
    service.save! if service.changed?
  end
end