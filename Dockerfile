FROM ubuntu:15.04

RUN /usr/bin/apt-get update && /usr/bin/apt-get install --no-install-recommends -qy ruby ruby-dev make g++ libsqlite3-dev libsqlite3-0 patch zlib1g-dev libghc-zlib-dev && gem install bundler --no-ri --no-rdoc
ADD Gemfile /rails-app/Gemfile
ADD Gemfile.lock /rails-app/Gemfile.lock
WORKDIR /rails-app
RUN /usr/bin/env bundle install --without assets development test
RUN /usr/bin/apt-get -qy purge ruby-dev g++ make patch && /usr/bin/apt-get -qy autoremove
ADD . /rails-app
RUN find public -mindepth 1 -not -name 'assets' -not -name 'manifest-*.json' -print -delete
RUN chown -R www-data:www-data Gemfile.lock db tmp
USER www-data
CMD unicorn -h 0.0.0.0