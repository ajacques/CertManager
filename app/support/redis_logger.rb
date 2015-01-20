class RedisLogger < Logger::LogDevice
  def initialize(job_id)
    @job_id = job_id
    @redis = CertManager::Configuration.redis_client
  end
  def write(message)
    @redis.rpush("job_#{@job_id}_log", message)
  end
end