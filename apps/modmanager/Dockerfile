
FROM ghcr.io/trueforge-org/ubuntu:24.4

ARG VERSION

ENV S6_STAGE2_HOOK=/init-hook

RUN \
  apk add --no-cache \
    docker-cli && \

COPY /root /

VOLUME /modcache
