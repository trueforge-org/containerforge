
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    bind-tools \
    logrotate && \
# add local files
USER apps
COPY . /
COPY ./root /
