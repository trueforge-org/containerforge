FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:2f8d64c7eb825345ac24192c13f028804662cb3d6cc633df9dd8f394e042f738
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
