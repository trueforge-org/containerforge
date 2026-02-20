FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:e5507376cb59a4669ad6179bc43e081b150558c96ab8e06b558e3b62c71241c8

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ARG TARGETARCH=${TARGETARCH/amd64/x64}

# environment settings
ENV HOME="/config" \
    DUPLICATI__REQUIRE_DB_ENCRYPTION_KEY=true \
    DUPLICATI__SERVER_DATAFOLDER=/config \
    DUPLICATI__WEBSERVICE_PORT=8200 \
    DUPLICATI__WEBSERVICE_INTERFACE=any \
    DUPLICATI__WEBSERVICE_ALLOWED_HOSTNAMES=*

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    fonts-dejavu-core \
    gdebi-core && \
  echo "**** install duplicati ****" && \
  curl -L -o /tmp/duplicati.deb \
    "https://github.com/duplicati/duplicati/releases/download/v${VERSION}/duplicati-${VERSION}-linux-${TARGETARCH}-gui.deb" && \
  gdebi -n /tmp/duplicati.deb && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /

COPY ./ /

# ports and volumes
EXPOSE 8200
VOLUME /backups /config /source
