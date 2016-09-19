# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

# These gems aren't loaded in the final Docker container
if Rails.env.test? || Rails.env.development?
  require 'rubocop/rake_task'
  require 'flay_task'
  require 'flay' # Temporary workaround. See https://github.com/seattlerb/flay/issues/61
  require 'scss_lint/rake_task'
  require 'haml_lint/rake_task'
  require 'reek/rake/task'

  RuboCop::RakeTask.new

  FlayTask.new

  reek = Reek::Rake::Task.new
  reek.source_files = FileList['app/**/*.rb', 'lib/**/*.rb', 'config/**/*.rb']
  reek.fail_on_error = false

  SCSSLint::RakeTask.new do |t|
    t.files = ['app/assets/stylesheets']
  end

  HamlLint::RakeTask.new do |t|
    t.files = %w(app/views app/assets/templates)
  end

  task default: [:test, :rubocop, :scss_lint, :haml_lint]
end

task release: ['assets:clobber', 'assets:precompile']
