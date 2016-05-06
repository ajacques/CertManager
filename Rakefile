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
reek.source_files = FileList['app/**/*.rb', 'lib/**/*.rb', 'config/**/*.rb']
reek.fail_on_error = false

require 'scss_lint/rake_task'
SCSSLint::RakeTask.new do |t|
  t.files = ['app/assets/stylesheets']
end

require 'haml_lint/rake_task'

HamlLint::RakeTask.new do |t|
  t.files = ['app/views', 'app/templates']
end

task default: [:test, :rubocop, :scss_lint, :flay, :haml_lint]
