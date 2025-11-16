
FROM ghcr.io/trueforge-org/ubuntu:24.4

ARG VERSION

RUN \
  echo "**** install packages ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.22/main/$TARGETARCH/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:syslog-ng$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add -U --upgrade --no-cache \
    grep \
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

COPY root/ /

EXPOSE 5514/udp 6601/tcp 6514/tcp

VOLUME /config
