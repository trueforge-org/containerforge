FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:6694765a55a999799d0b37f806a0e0ba11ceb4dcb22392b63f1b74b4123ea175
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
