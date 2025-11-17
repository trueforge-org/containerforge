
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:c0d65e9793c7c477d7c27c7936d9aa40dad9a404fdf49f1cfdd69da7220988bb

ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    libdbi-drivers \
    paho-mqtt-c \
    syslog-ng==${VERSION} \
    syslog-ng-add-contextual-data \
    syslog-ng-amqp \
    syslog-ng-graphite \
    syslog-ng-http \
    syslog-ng-json \
    syslog-ng-map-value-pairs \
    syslog-ng-python \
    syslog-ng-redis \
    syslog-ng-scl \
    syslog-ng-sql \
    syslog-ng-stardate \
    syslog-ng-stomp \
    syslog-ng-tags-parser \
    syslog-ng-xml && \
  rm -rf \
    /tmp/*

USER apps
COPY . /
COPY ./root /

EXPOSE 5514/udp 6601/tcp 6514/tcp

VOLUME /config
