FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

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
