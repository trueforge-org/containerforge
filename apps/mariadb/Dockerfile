
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

# environment variables
ENV MYSQL_DIR="/config"
ENV DATADIR="$MYSQL_DIR/databases"

RUN \
  echo "**** install runtime packages ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.22/main/$TARGETARCH/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:mariadb$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    gnupg \
    logrotate \
    mariadb==${VERSION} \
    mariadb-backup==${VERSION} \
    mariadb-client==${VERSION} \
    mariadb-common==${VERSION} \
    mariadb-server-utils==${VERSION} && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3306

VOLUME /config
