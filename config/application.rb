require File.expand_path('boot', __dir__)

if ENV['RAILS_ENV'] == 'assets'
  %w[
    action_controller/railtie
    active_job/railtie
    action_view/railtie
    sprockets/railtie
  ].each do |railtie|
    require railtie
  end
else
  require 'rails/all'
end

require 'opencensus/trace/integrations/rails'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CertManager
  class CertManager::Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += %w[support exceptions].map { |f| Rails.root.join('app', f) }
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '*')]

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.action_dispatch.rescue_responses['NotAuthorized'] = :unauthorized

    # Security headers are injected by the front-end proxy
    config.action_dispatch.default_headers = {}

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
