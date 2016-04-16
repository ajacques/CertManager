FROM ubuntu:16.04

RUN /usr/bin/apt-get update && /usr/bin/apt-get install --no-install-recommends -qy ruby ruby-dev make g++ libsqlite3-dev libsqlite3-0 patch zlib1g-dev libpq5 libpq-dev libghc-zlib-dev && gem install bundler --no-ri --no-rdoc
ADD Gemfile /rails-app/Gemfile
ADD Gemfile.lock /rails-app/Gemfile.lock
WORKDIR /rails-app
RUN /usr/bin/env bundle install
RUN /usr/bin/apt-get -qy purge libsqlite3-dev zlib1g-dev libghc-zlib-dev libpq-dev ruby-dev g++ make patch && /usr/bin/apt-get -qy autoremove
RUN /bin/rm -rf /var/lib/gems/2.1.0/cache /var/cache/* /var/lib/apt/lists/*
ADD . /rails-app
RUN RAILS_ENV=assets bundle exec rake assets:precompile
RUN find public -mindepth 1 -not -name 'assets' -not -name '.sprockets-manifest-*.json' -not -name 'components-*.js' -print -delete
RUN find . -type f -print -exec chmod 444 {} \; && find . -type d -print -exec chmod 555 {} \;
RUN chown www-data:www-data db && chown -R www-data:www-data tmp
RUN chmod 755 db && find tmp -type d -print -exec chmod 755 {} \;
RUN find bin -type f -print -exec chmod 544 {} \;
USER www-data
EXPOSE 8080
ENTRYPOINT ["/usr/bin/ruby", "/rails-app/bin/bundle", "exec"]
CMD ["/usr/local/bin/unicorn", "-o", "0.0.0.0", "-p", "8080", "-c", "unicorn.rb"]
