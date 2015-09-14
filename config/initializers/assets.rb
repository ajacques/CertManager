# Be sure to restart your server when you modify this file.
Rails.application.configure do
  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  assets.register_mime_type 'text/html', extensions: ['.html']
  assets.register_engine '.haml', Tilt::HamlTemplate
  config.assets.paths << Rails.root.join('app', 'assets', 'templates')

  assets.context_class.class_eval do
    include Rails.application.routes.url_helpers
    include Rails.application.routes.mounted_helpers
    include ActionView::Helpers
  end
end
