FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:5b73e70bff124668c9432d50ac6bcdfb961c11e82debe5004aa68895feab0238
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
