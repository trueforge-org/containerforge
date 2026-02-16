
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174

ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
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

WORKDIR /config
