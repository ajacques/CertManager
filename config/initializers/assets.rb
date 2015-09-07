# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Sprockets.register_mime_type 'text/html', extensions: ['.html']
Sprockets.register_engine '.haml', Tilt::HamlTemplate
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'templates')

Rails.application.assets.context_class.class_eval do
  include ActionView
  include ActionView::Helpers
end
