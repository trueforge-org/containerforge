FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:51a8cb185ca9a4d55f1ebff3d3d063ea49262babb5096ddba4a1f5432995ed01
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
