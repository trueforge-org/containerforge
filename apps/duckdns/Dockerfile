
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:63879ad04337bfb36d309809a30de1522a0ac4ab22b117d727c6fef598d41321

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
COPY ./root /

WORKDIR /config
VOLUME /config
