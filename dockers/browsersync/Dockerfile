FROM ubuntu:15.04

RUN apt-get update && apt-get install -qy npm nodejs build-essential
RUN npm install -g browser-sync@2.7.12
WORKDIR /app
USER www-data
ENTRYPOINT ["/usr/bin/nodejs", "/usr/local/bin/browser-sync"]
