if ENV['LOGSTASH_ENABLED']
  logstash = LogStashLogger.new type: :udp, host: 'logstash', port: 5228

  ElasticsearchHttpRequestLogger.logstash = logstash
  ElasticsearchHttpRequestLogger.attach_to(:action_controller)

  ElasticsearchJobLogger.logstash = logstash
  ElasticsearchJobLogger.attach_to(:active_job)
end

if ENV.key? 'SENTRY_DSN'
  Raven.configure do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.release = File.read('.git/refs/heads/master').chomp
    config.async = ->(event) { SentryReportJob.perform_later(event) }
  end
end
