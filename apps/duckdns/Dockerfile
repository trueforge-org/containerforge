
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:5fa3c2cf644e1cf005b5ee0feac4b0d0041f65850fb1991bef3926c45a9a371c

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dnsutils \
    logrotate && \
  rm -rf /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /


WORKDIR /config
VOLUME /config
