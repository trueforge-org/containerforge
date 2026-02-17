
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:e96499687b5d1319878f006ab22dfdfcbfb7c059fc2d4538685636e026b71e87

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
