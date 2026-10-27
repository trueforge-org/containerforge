FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:9ec5de91a1fb401ba4739f36a6b8dfaf70fd8dc75735fdf608e23392f9be29ba
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
