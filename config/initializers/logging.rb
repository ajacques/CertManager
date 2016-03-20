config = Rails.application.config

logstash = LogStashLogger.new type: :udp, host: 'logstash', port: 5228
# Rails.logger = ActiveSupport::TaggedLogging.new logstash
config.log_level = :debug

ElasticsearchHttpRequestLogger.logstash = logstash
ElasticsearchHttpRequestLogger.attach_to(:action_controller)
