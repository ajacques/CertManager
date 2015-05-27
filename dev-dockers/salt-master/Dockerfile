FROM ubuntu:15.04

RUN apt-get update && apt-get install -y software-properties-common python-pip && pip install -U halite && pip install CherryPy && add-apt-repository -y ppa:saltstack/salt && apt-get update && apt-get install -y salt-api salt-master
ADD master /etc/salt/master
CMD salt-master -d && salt-api
