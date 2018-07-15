source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'

# User Interface Gems
gem 'bootstrap_form'
gem 'haml'
gem 'haml-rails'

# Asset Management
gem 'mini_racer', platform: :ruby
gem 'react-rails'
gem 'webpacker'

gem 'will_paginate'

gem 'redis'
gem 'redis-session-store'

gem 'acme-client'
gem 'r509' # SSL certificate utilities

# Database
gem 'pg', '~> 0.18', platform: :ruby # Postgres

gem 'resque' # Background job execution
gem 'resque-scheduler'

gem 'rest-client'

gem 'logstash-logger'
gem 'request_store'
gem 'secure_headers'

gem 'zipkin-tracer'

gem 'jwt'

group :assets, :development do
  gem 'autoprefixer-rails'
  gem 'bootstrap-sass'
  gem 'i18n-js', '>= 3.0.0.rc11'
  gem 'js-routes'
  gem 'sprockets'
  gem 'sprockets-es6'
end

group :assets do
  # Use SCSS for stylesheets
  gem 'sass-rails'
  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier'
end

group :development do
  gem 'mocha'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Use sqlite3 as the database for Active Record
  gem 'simplecov', platform: :ruby

  # Coding quality
  gem 'flay', require: false
  gem 'haml-lint', require: false
  gem 'reek', require: false
  gem 'rubocop', require: false
  gem 'scss_lint', require: false
end

group :development, :production do
  gem 'sentry-raven'
end

gem 'nokogiri', '>= 1.8.1'
gem 'tzinfo-data'
gem 'unicorn', platform: :ruby
