# Be sure to restart your server when you modify this file.
Rails.application.config.assets.configure do |assets|
  # Version of your assets, change this if you want to expire all your assets.
  assets.version = '1.0'

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  assets.register_mime_type 'text/html', extensions: ['.haml']
  assets.register_engine '.haml', Tilt::HamlTemplate

  assets.context_class.class_eval do
    include Rails.application.routes.url_helpers
    include Rails.application.routes.mounted_helpers
    include ActionView::Helpers
  end
end
