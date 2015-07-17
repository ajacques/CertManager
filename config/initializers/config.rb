require 'app/configuration'
require 'app/instrumented_redis'

email_delivery = CertManager::Configuration.email_delivery
secret_key = CertManager::Configuration.secret_key
resque = CertManager::Configuration.resque

config = Rails.application.config
if email_delivery
  email_delivery.each do |key, value|
    ActionMailer::Base.send("#{key}=", value)
  end
end

if secret_key
  config.secret_token = secret_key
end

if resque
  Resque.redis = resque
end

config.logger = ActiveSupport::TaggedLogging.new LogStashLogger.new type: :udp, host: 'logstash', port: 5228
config.log_level = :debug