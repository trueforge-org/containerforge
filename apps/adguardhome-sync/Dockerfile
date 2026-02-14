
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:ede54cb88fd5efef6f41610146f10b4399f5e584d9227202b6c14a515a35e94e

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

RUN echo "*** Installing AdGuardHome Sync ***" && \
  curl -o \
    /tmp/adguardhomesync.tar.gz -L \
    "https://github.com/bakito/adguardhome-sync/releases/download/v${VERSION}/adguardhome-sync_${VERSION#v}_linux_$TARGETARCH.tar.gz" && \
  tar xzf \
    /tmp/adguardhomesync.tar.gz -C \
    /app/ && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm /tmp/adguardhomesync.tar.gz

USER apps
COPY . /
COPY ./root /

EXPOSE 8080

VOLUME /config
