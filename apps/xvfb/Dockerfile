FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d
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
