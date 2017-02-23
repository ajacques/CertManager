require 'app/configuration'
require 'app/instrumented_redis'

unless Rails.env.test? || Rails.env.assets?
  resque = CertManager::Configuration.resque

  Resque.redis = resque if resque
end
