FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:bc182517d87eb71b9a71e11941223716611ebe6002864b1a28d03cca78fa5a35
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
