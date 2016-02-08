source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.5.1'

# User Interface Gems
gem 'haml'
gem 'haml-rails'
gem 'bootstrap_form'
gem 'will_paginate'

gem 'redis'
gem 'redis-session-store'

gem 'r509' # SSL certificate utilities
gem 'acme-client'

gem 'resque' # Background job execution
gem 'resque-scheduler'
gem 'pg' # Postgres

group :assets, :development do
  # Use jquery as the JavaScript library
  gem 'jquery-rails'
  # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
  gem 'turbolinks'

  gem 'bootstrap-sass'
  gem 'react-rails'
  gem 'js-routes'

  gem 'sprockets'
  gem 'sprockets-es6'
end

group :assets do
  # Use SCSS for stylesheets
  gem 'sass-rails'
  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier'
  # Use CoffeeScript for .js.coffee assets and views
  gem 'coffee-rails'
end

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
  gem 'simplecov', platform: :ruby
  gem 'mocha'

  # Coding quality
  gem 'rubocop', require: false
  gem 'flay', require: false
  gem 'reek', require: false
end

gem 'unicorn', platform: :ruby

gem 'nokogiri', '>= 1.6.7.2'

gem 'rails-html-sanitizer', '~> 1.0.3'
