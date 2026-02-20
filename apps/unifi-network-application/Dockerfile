
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:36c48bc0fd413c8ef2ae9761b1decc96fa8295f44407a9b7280bd137c2109355

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

# add local files
USER apps
COPY --chmod=0755 container-test.yaml /container-test.yaml
COPY ./root/ /
COPY ./ /

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8443 8843 8880
