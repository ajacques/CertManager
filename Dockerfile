FROM alpine:3.5

ADD . /rails-app
WORKDIR /rails-app
RUN export BUILD_PKGS="ruby-dev build-base postgresql-dev libxml2-dev ruby-io-console linux-headers" \
  && apk --update --upgrade add ruby ruby-json ruby-bigdecimal nodejs $BUILD_PKGS \

  && gem install -N bundler \
  && env bundle install --without test development \

# Generate compiled assets + manifests
  && RAILS_ENV=assets rake release \

# Remove the source assets because we don't need them anymore
  && rm -rf app/assets/* \

# Uninstall development headers/packages
  && apk del $BUILD_PKGS \
  && find / -type f -iname \*.apk-new -delete \
  && rm -rf /var/cache/apk/* \

  && rm -rf /var/lib/gems/*/cache/* ~/.gem /var/cache/* /root tmp/* \

# All files/folders should be owned by root by readable by www-data
  && find . -type f -print -exec chmod 444 {} \; \
  && find . -type d -print -exec chmod 555 {} \; \

  && chown -R www-data:www-data tmp \
  && chmod 755 db && find tmp -type d -print -exec chmod 755 {} \; \
  && find bin -type f -print -exec chmod 544 {} \;
ENV RAILS_ENV=production
USER www-data
EXPOSE 8080
ENTRYPOINT ["/usr/bin/ruby", "/rails-app/bin/bundle", "exec"]
CMD ["/usr/local/bin/unicorn", "-o", "0.0.0.0", "-p", "8080", "-c", "unicorn.rb", "--no-default-middleware"]
