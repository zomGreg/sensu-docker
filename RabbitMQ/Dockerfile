FROM library/rabbitmq
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get install -y curl wget openssl supervisor

ADD certs /tmp/ssl_certs
ADD install-sensu.sh /tmp/
RUN /tmp/install-sensu.sh

ADD setup-rabbitmq.sh /tmp/
ADD supervisor.conf /etc/supervisor/conf.d/sensu.conf

RUN /tmp/setup-rabbitmq.sh

CMD ["/usr/bin/supervisord"]
