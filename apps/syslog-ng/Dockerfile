
FROM ghcr.io/trueforge-org/python:3.14.4@sha256:622c7c1053c59c31674e5c31b88b1a7cfa61b0f5fbabebb38dd9a4ab5e2f6ee1

ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libdbi1t64 \
    libpaho-mqtt1.3 \
    syslog-ng \
    syslog-ng-mod-add-contextual-data \
    syslog-ng-mod-amqp \
    syslog-ng-mod-graphite \
    syslog-ng-mod-http \
    syslog-ng-mod-python \
    syslog-ng-mod-redis \
    syslog-ng-scl \
    syslog-ng-mod-sql \
    syslog-ng-mod-stardate \
    syslog-ng-mod-stomp \
    syslog-ng-mod-xml-parser && \
  rm -rf \
    /tmp/*

USER apps
COPY --chmod=0755 . /


EXPOSE 5514/udp 6601/tcp 6514/tcp

VOLUME /config

WORKDIR /config
