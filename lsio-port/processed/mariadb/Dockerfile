
FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# set version label
ARG VERSION
ARG MARIADB_VERSION

# environment variables
ENV MYSQL_DIR="/config"
ENV DATADIR="$MYSQL_DIR/databases"

RUN \
  echo "**** install runtime packages ****" && \
  if [ -z ${MARIADB_VERSION+x} ]; then \
    MARIADB_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.22/main/$TARGETARCH/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:mariadb$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    gnupg \
    logrotate \
    mariadb==${MARIADB_VERSION} \
    mariadb-backup==${MARIADB_VERSION} \
    mariadb-client==${MARIADB_VERSION} \
    mariadb-common==${MARIADB_VERSION} \
    mariadb-server-utils==${MARIADB_VERSION} && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3306

VOLUME /config
