FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:205c6561352214872c61edea4909f29afe9be1eee6c61430ce627ca757c137ed
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
