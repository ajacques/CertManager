class DeployServiceJob < ApplicationJob
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
    begin
      block.call
      redis.set("job_#{job.job_id}_status", 3)
    rescue Error => ex
      Rails.logger.error ex
      raise ex
    end
    Rails.logger = plogger
  end

  def perform(service)
    Rails.logger.info 'Deploying service'
    service.deploy
    service.save! if service.changed?
  end
end
