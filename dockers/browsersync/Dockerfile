FROM ubuntu:16.04

RUN apt-get update && apt-get install -qy --no-install-recommends npm nodejs build-essential \
  && npm install -g browser-sync@2.7.12 \
  && apt-get purge -qy build-essential npm \
  && apt-get -qy autoremove \
  && rm -rf /var/cache/* /var/lib/apt/lists/*
WORKDIR /app
USER www-data
ENTRYPOINT ["/usr/bin/nodejs", "/usr/local/bin/browser-sync"]
