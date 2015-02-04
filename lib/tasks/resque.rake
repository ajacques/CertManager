require 'resque/tasks'
require 'resque/scheduler/tasks'
require 'app/configuration'

namespace :resque do
  task :setup => :environment do
    require 'resque'

    resque = CertManager::Configuration.resque

    Resque.redis = resque
  end
  task :setup_schedule => :setup do
    require 'resque-scheduler'

    Resque.schedule = YAML.load_file("#{Rails.root}/config/scheduled_jobs.yml")
  end
  task :scheduler_setup => :setup_schedule
end