require 'app/configuration'
require 'app/instrumented_redis'

unless Rails.env.test?
  resque = CertManager::Configuration.resque

  Resque.redis = resque if resque
end
