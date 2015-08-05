FROM ubuntu:15.04

RUN apt-get update && apt-get install -y software-properties-common python-pip supervisor && pip install -U halite && pip install CherryPy && add-apt-repository -y ppa:saltstack/salt && apt-get update && apt-get install -y salt-api salt-master
ADD master /etc/salt/master
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
