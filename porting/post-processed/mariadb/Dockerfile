
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:a4b6def0d259d9473207e9633dc5c1849f8b3c7ebc38f0a2bfd666a8b92151ed

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment variables
ENV MYSQL_DIR="/config"
ENV DATADIR="$MYSQL_DIR/databases"

RUN \
  echo "**** install runtime packages ****" && \
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
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 3306

VOLUME /config
