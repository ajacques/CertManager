# CertManager [![Build Status](https://travis-ci.org/ajacques/CertManager.svg?branch=master)](https://travis-ci.org/ajacques/CertManager)
Web application designed to simplify SSL certificate management

## Production Setup
Helm template is coming soon. The docker-compose should work.

## Developer Setup

This setup assumes that you use the docker-gen+NGINX docker environment. You can develop without it,
instead of using domain names you'll have to connect directly the NGINX instance.

### Docker
* Setup docker-compose (>= 1.2.0)
* Build Docker images (docker-compose build)
* Setup file permissions (bin/init_dev_env)
* Launch Docker images (docker-compose up)
* Configure database (bin/seed)

NOTE: We currently use the production Docker container to host the application, 
but its missing a few of the gems that might be needed to run. Mainly, the Bundler
groups development and assets are stripped from the container. You may have to modify
the Dockerfile on line 7 to allow them to be built-in for your development.

We should setup a shared data volume for rubygems to prevent them from having to be
downloaded every time it's built.

## Problem Areas

The tricky areas with setting up the environment is making sure that the gems are installed correctly. Currently we need to edit the Dockerfile to remove the '--without assets development test' block. This isn't really a good practice, but we don't want those gems in production.

## Architecture

* web: Unicorn Rails app server - Runs the website
* nginx: Front-end reverse proxy. Doesn't do much in development but is there to allow for prod verification. Will handle static files and load balancing
* redis: Ephemeral data store - Used for caching host deployment status, CRL responses, and job scheduling for the works
* db: Permanent store for all application data (certificates, users, services) It's a Postgres instance
* worker: Resque instance - Used for background job scheduling such as the periodic deployment status refresh and revocation checks
* scheduler: Resque job scheduler - Used to schedule the periodic jobs. See config/scheduled_jobs.yml
* browsersync: Useful development tool that automatically refreshes your web browser when you update CSS, JS, and HTML
