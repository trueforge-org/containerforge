FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:e855efee08935623aad3a45e3e554e52216b53d07105a9b3beb585ea1e78352c
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
