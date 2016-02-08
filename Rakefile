# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'flay_task'
FlayTask.new

require 'reek/rake/task'
reek = Reek::Rake::Task.new
reek.source_files = FileList['app/**/*.rb', 'lib/**/*.rb']
reek.fail_on_error = false

task default: [:rubocop, :flay, :reek]
