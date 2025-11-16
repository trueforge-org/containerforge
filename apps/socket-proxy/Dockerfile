
FROM docker.io/alpine:3.22

# set version label
ARG VERSION

# install packages
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache \
    alpine-release \
    curl \
    tzdata && \
  if [ -z ${VERSION+x} ]; then \
  VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.22/main/$TARGETARCH/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:haproxy$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
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
COPY root/ /

ENTRYPOINT ["/docker-entrypoint.sh"]
