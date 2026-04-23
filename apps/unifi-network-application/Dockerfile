
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:01cc09f895d289305f12087ced3d9b01ad74ec5e958384d3274a7caa87a94c37

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV DEBIAN_FRONTEND="noninteractive"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    jsvc \
    logrotate \
    openjdk-17-jre-headless \
    unzip && \
  echo "**** install unifi ****" && \
  UNIFI_DOWNLOAD=$(curl -sX GET "https://fw-update.ubnt.com/api/firmware?filter=eq~~product~~unifi-controller&filter=eq~~platform~~unix&filter=eq~~channel~~release&sort=-version" \
  | jq -r "._embedded.firmware[] | select(.version | test(\"v${VERSION}\")) | ._links.data.href") && \
  mkdir -p /app && \
  curl -o \
  /tmp/unifi.zip -L \
    "${UNIFI_DOWNLOAD}" && \
  unzip /tmp/unifi.zip -d /usr/lib && \
  mv /usr/lib/UniFi /usr/lib/unifi && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
USER apps
COPY --chmod=0755 . /
COPY ./ /

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8443 8843 8880
