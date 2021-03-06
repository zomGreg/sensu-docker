#!/bin/bash

shopt -s extglob

usage() {
    cat <<EOF
usage: $0 option

OPTIONS:
   help       Show this message
   clean      Clean up
   generate   Generate SSL certificates for Sensu
EOF
}

clean() {
    rm -rf ssl RabbitMQ/certs Redis/certs Graphite/certs Influxdb/certs Grafana/certs Elasticsearch/certs Sensu/certs
}

generate() {
    workdir=$(pwd)
    mkdir ssl && cd ssl
    mkdir -p client server sensu_ca/private sensu_ca/certs
    touch sensu_ca/index.txt
    echo 01 > sensu_ca/serial
    cd sensu_ca
    openssl req -x509 -config $workdir/openssl.cnf -newkey rsa:2048 -days 1825 -out cacert.pem -outform PEM -subj /CN=SensuCA/ -nodes
    openssl x509 -in cacert.pem -out cacert.cer -outform DER
    cd ../server
    openssl genrsa -out key.pem 2048
    openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=server/ -nodes
    cd ../sensu_ca
    openssl ca -config $workdir/openssl.cnf -in ../server/req.pem -out ../server/cert.pem -notext -batch -extensions server_ca_extensions
    cd ../server
    openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:c7d48237bc8fac87fdc239670fadec2b
    cd ../client
    openssl genrsa -out key.pem 2048
    openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=client/ -nodes
    cd ../sensu_ca
    openssl ca -config $workdir/openssl.cnf -in ../client/req.pem -out ../client/cert.pem -notext -batch -extensions client_ca_extensions
    cd ../client
    openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:c7d48237bc8fac87fdc239670fadec2b
    cd ../../
}

setup_folders() {
  mkdir -p RabbitMQ/certs Redis/certs Graphite/certs Influxdb/certs Grafana/certs Elasticsearch/certs Sensu/certs
  cp -R ssl/* RabbitMQ/certs
  cp -R ssl/client Redis/certs
  cp -R ssl/client Sensu/certs
  cp -R ssl/client Graphite/certs
  cp -R ssl/client Grafana/certs
  cp -R ssl/client Elasticsearch/certs
  cp -R ssl/client Influxdb/certs
}

if [ "$1" = "generate" ]; then
    echo "Generating SSL certificates for Sensu ..."
    generate
    setup_folders
elif [ "$1" = "clean" ]; then
    echo "Cleaning up ..."
    clean
else
    usage
fi
