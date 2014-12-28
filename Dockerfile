FROM debian:stable

RUN /usr/bin/apt-get update && /usr/bin/apt-get install -qy ruby1.9.1 ruby1.9.1-dev make libmysqlclient-dev
RUN gem install bundler --no-ri --no-rdoc
ADD . /rails-app
WORKDIR /rails-app
RUN /usr/bin/env bundle install --without development test assets
RUN chown www-data:www-data /rails-app/Gemfile.lock