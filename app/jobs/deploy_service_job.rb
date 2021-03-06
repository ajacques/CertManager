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
    rescue ::StandardError => e
      Rails.logger.error e
      redis.set("job_#{job.job_id}_status", 2)
      raise e
    end
    Rails.logger = plogger
  end

  def perform(service)
    Rails.logger.info 'Deploying service'
    service.deploy
    service.last_deployed = Time.now.utc
    service.save! if service.changed?
  end
end
