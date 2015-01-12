FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise universe" >> /etc/apt/sources.list
RUN apt-get install -y curl wget
# RUN echo '127.0.0.1 localhost.localdomain localhost' >> /etc/hosts
RUN useradd -d /home/sensu -m -s /bin/bash sensu
RUN echo sensu:sensu | chpasswd

ADD policy-rc.d /usr/sbin/policy-rc.d

ADD sensu_ca /tmp/
ADD ssl_certs.sh /tmp/
ADD install-sensu.sh /tmp/
RUN /tmp/install-sensu.sh
ADD config.json /etc/sensu/
ADD client.json /etc/sensu/conf.d/client.json

EXPOSE 15672:15672
EXPOSE 8080
EXPOSE 3000
ADD start.sh /tmp/start.sh
CMD /tmp/start.sh
