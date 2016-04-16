#!/bin/sh
docker save certmanager_web | sudo TMPDIR=/home/adam/tmp ~/tools/docker-squash --from=da24275a9cab --verbose -t docker.technowizardry.net/certmanager_web:1 | docker load
