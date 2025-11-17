
FROM ghcr.io/trueforge-org/ubuntu:24.4

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

RUN \
  apk add --no-cache \
    yq-go && \
  mkdir -p /app/adguardhome-sync && \
  echo "*** Installing AdGuardHome Sync ***" && \
  curl -o \
    /tmp/adguardhomesync.tar.gz -L \
    "https://github.com/bakito/adguardhome-sync/releases/download/v${VERSION}/adguardhome-sync_${VERSION#v}_linux_$TARGETARCH.tar.gz" && \
  tar xzf \
    /tmp/adguardhomesync.tar.gz -C \
    /app/adguardhome-sync/ && \
  echo "*** Cleaning Up ***" && \
  rm /tmp/adguardhomesync.tar.gz

USER apps
COPY . /
COPY ./root /

EXPOSE 8080

VOLUME /config
