FROM ubuntu:latest

RUN apt-get update && apt-get install -qy npm nodejs build-essential
RUN npm install -g browser-sync
WORKDIR /app
USER www-data
ENTRYPOINT ["/usr/bin/nodejs", "/usr/local/bin/browser-sync"]
