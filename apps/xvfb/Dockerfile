FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:b5600d4261e0d35c7ace5c90b9abed37532c09265206daadeb387ad723c5be5e
ARG VERSION
ARG TARGETARCH
USER root
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends xvfb && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config
