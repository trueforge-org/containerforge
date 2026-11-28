FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label (apt package version, not the upstream 3.8.2 tag)
ARG VERSION
ARG VENDOR
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    "kiwix-tools=${VERSION}" && \
  echo "**** config dir ****" && \
  install -d -o apps -g apps /config && \
  echo "**** cleanup ****" && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

# copy local files
COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080

VOLUME /config

WORKDIR /config
