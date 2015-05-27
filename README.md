# CertManager
Web application designed to simplify SSL certificate management

## Setup
### Docker
* Setup docker-compose (>= 1.2.0)
* Build Docker images (docker-compose build)
* Setup file permissions sh bin/init_dev_env
* Launch Docker images (docker-compose up)
* Configure database (docker exec -ti certmanager_web_1 bin/bundle exec rake db:setup)

NOTE: We currently use the production Docker container to host the application, 
but its missing a few of the gems that might be needed to run. Mainly, the Bundler
groups development and assets are stripped from the container. You may have to modify
the Dockerfile on line 7 to allow them to be built-in for your development.

We should setup a shared data volume for rubygems to prevent them from having to be
downloaded every time it's built.

