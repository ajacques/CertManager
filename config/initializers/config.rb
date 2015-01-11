require 'ostruct'
require 'app/configuration'

email_delivery = CertManager::Configuration.email_delivery
secret_key = CertManager::Configuration.secret_key
resque = CertManager::Configuration.resque

if email_delivery
  email_delivery.each do |key, value|
    ActionMailer::Base.send("#{key}=", value)
  end
end

if secret_key
  Rails.application.config.secret_token = secret_key
end

if resque
  Resque.redis = resque
end