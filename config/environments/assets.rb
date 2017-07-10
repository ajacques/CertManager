Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new output: { comments: :none }
  config.assets.css_compressor = :sass

  config.assets.precompile += %w[server_rendering.js components.js]

  # Generate digests for assets URLs.
  config.assets.digest = true

  config.compact_haml = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use Production built version of React
  config.react.variant = :production
end
