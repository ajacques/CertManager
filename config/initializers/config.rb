require 'app/configuration'
require 'app/instrumented_redis'

email_delivery = CertManager::Configuration.email_delivery
secret_key = CertManager::Configuration.secret_key
resque = CertManager::Configuration.resque

if email_delivery
  email_delivery.each do |key, value|
    ActionMailer::Base.send("#{key}=", value)
  end
end

Rails.application.config.secret_token = secret_key if secret_key

Resque.redis = resque if resque
