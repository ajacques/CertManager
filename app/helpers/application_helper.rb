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

  def time_ago_enhanced_block(time)
    relative_time = time_ago_in_words(time, include_seconds: true)
    actual_time = l(time.in_time_zone(current_user.time_zone), format: :month_day_time)
    capture_haml do
      haml_tag :abbr, relative_time, title: actual_time
    end
  end
end
