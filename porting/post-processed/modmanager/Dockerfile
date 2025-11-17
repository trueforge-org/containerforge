
FROM ghcr.io/trueforge-org/ubuntu:24.4

ARG VERSION
ARG TARGETARCH
USER root

ENV S6_STAGE2_HOOK=/init-hook

RUN \
  apk add --no-cache \
    docker-cli && \
USER apps
COPY . /
COPY ./root /

VOLUME /modcache
