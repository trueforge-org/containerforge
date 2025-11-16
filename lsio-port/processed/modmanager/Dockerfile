
FROM ghcr.io/linuxserver/baseimage-alpine:3.22

ARG VERSION

ENV S6_STAGE2_HOOK=/init-hook

RUN \
  apk add --no-cache \
    docker-cli && \

COPY /root /

VOLUME /modcache
