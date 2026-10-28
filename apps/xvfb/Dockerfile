FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:cab29d37a3d5e2d93201d98363c0169152d9d7147518121900f5587da719df62
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
