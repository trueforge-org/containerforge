
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    bind-tools \
    logrotate && \

# add local files
COPY root/ /
