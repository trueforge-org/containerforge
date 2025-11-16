
FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# set version label
ARG VERSION
ARG DUCKDNS_VERSION

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    bind-tools \
    logrotate && \

# add local files
COPY root/ /
