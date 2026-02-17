
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:e96499687b5d1319878f006ab22dfdfcbfb7c059fc2d4538685636e026b71e87

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
COPY . /
COPY ./root /

WORKDIR /config
VOLUME /config
