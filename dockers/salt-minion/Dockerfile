FROM ubuntu:15.04
RUN apt-get update && apt-get install -y software-properties-common supervisor \
  && add-apt-repository -y ppa:saltstack/salt \
  && apt-get update \
  && apt-get install --no-install-recommends -y salt-minion
RUN /bin/rm -rf /var/cache/
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]