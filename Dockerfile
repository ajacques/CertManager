FROM ubuntu:latest

RUN /usr/bin/apt-get update && /usr/bin/apt-get install -qy ruby1.9.1 ruby1.9.1-dev make g++ libmysqlclient-dev libsqlite3-dev nodejs patch
RUN gem install bundler --no-ri --no-rdoc
ADD . /rails-app
WORKDIR /rails-app
RUN /usr/bin/env bundle install
RUN chown www-data:www-data /rails-app/Gemfile.lock
EXPOSE 3000
CMD unicorn -h 0.0.0.0