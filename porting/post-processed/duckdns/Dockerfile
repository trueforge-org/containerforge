
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:a4b6def0d259d9473207e9633dc5c1849f8b3c7ebc38f0a2bfd666a8b92151ed

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
