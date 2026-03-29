
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:8f6de6a5c28a657e36d1b7630580eaf27788aac5d0603d18d644a1ac1332f061

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
