require 'app/configuration'
require 'app/instrumented_redis'

resque = CertManager::Configuration.resque

Resque.redis = resque if resque
