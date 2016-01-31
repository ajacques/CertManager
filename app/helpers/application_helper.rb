module ApplicationHelper
  def bg_refresh_last_update
    redis = CertManager::Configuration.redis_client
    last_run = redis.get('CertBgRefresh_LastRun') || 0
    Time.at(last_run.to_f)
  end

  def bg_refresh_last_update_in_words
    redis = CertManager::Configuration.redis_client
    last_run = redis.get('CertBgRefresh_LastRun') || nil
    return 'never' if last_run.nil?
    "#{time_ago_in_words Time.at(last_run.to_f)} ago"
  end

  def bg_refresh_out_of_date
    (Time.now - bg_refresh_last_update) > 10.minutes
  end

  def redis_client
    CertManager::Configuration.redis_client
  end
end
