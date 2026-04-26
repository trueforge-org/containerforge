
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:fdcc4e24cd12eed53bb1338ab6dd5651f5326bcbb98920aa3e8f0c8f5c9b2458

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
