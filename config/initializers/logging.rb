config = Rails.application.config

logstash = LogStashLogger.new type: :udp, host: 'logstash', port: 5228
config.log_level = :debug

ElasticsearchHttpRequestLogger.logstash = logstash
ElasticsearchHttpRequestLogger.attach_to(:action_controller)

ElasticsearchJobLogger.logstash = logstash
ElasticsearchJobLogger.attach_to(:active_job)
