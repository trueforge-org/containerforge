
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:cc82810600df75ed627ea3453ff80a6fc5204ea48139834e41f0c74e685ef776

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
