FROM ubuntu
RUN apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:saltstack/salt && apt-get update && apt-get install -y salt-minion nginx
CMD salt-minion
