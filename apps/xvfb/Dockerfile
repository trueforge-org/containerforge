FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:24efb13c405c262ba2d501640e0a70e0454439ed722125055b11814ff49323db
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
