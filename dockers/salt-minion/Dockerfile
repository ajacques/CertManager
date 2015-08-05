FROM ubuntu:15.04
RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:saltstack/salt && apt-get update && apt-get install --no-install-recommends -y salt-minion
RUN /bin/rm -rf /var/cache/
CMD salt-minion
