
FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:a4b6def0d259d9473207e9633dc5c1849f8b3c7ebc38f0a2bfd666a8b92151ed

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# install packages
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache \
    haproxy==${VERSION} && \
  apk del --no-cache \
    curl && \
  rm -rf \
    /etc/haproxy \
    /tmp/*

ENV ALLOW_RESTARTS=0 \
  ALLOW_STOP=0 \
  ALLOW_START=0 \
  AUTH=0 \
  BUILD=0 \
  COMMIT=0 \
  CONFIGS=0 \
  CONTAINERS=0 \
  DISTRIBUTION=0 \
  EVENTS=1 \
  EXEC=0 \
  IMAGES=0 \
  INFO=0 \
  LOG_LEVEL=info \
  NETWORKS=0 \
  NODES=0 \
  PING=1 \
  PLUGINS=0 \
  POST=0 \
  SECRETS=0 \
  SERVICES=0 \
  SESSION=0 \
  SOCKET_PATH=/var/run/docker.sock \
  SWARM=0 \
  SYSTEM=0 \
  TASKS=0 \
  VERSION=1 \
  VOLUMES=0

# add local files
USER apps
COPY . /
COPY ./root /

