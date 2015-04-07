FROM ubuntu:latest

RUN /usr/bin/apt-get update && /usr/bin/apt-get install -qy ruby ruby-dev make g++ libmysqlclient-dev libsqlite3-dev nodejs patch && gem install bundler --no-ri --no-rdoc
ADD . /rails-app
WORKDIR /rails-app
RUN /usr/bin/env bundle install && chown www-data:www-data /rails-app/Gemfile.lock
EXPOSE 3000
CMD unicorn -h 0.0.0.0