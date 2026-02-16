
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    imagemagick \
    php8.4-bz2 \
    php8.4-dom \
    php8.4-gd \
    php8.4-ldap \
    php8.4-mysql \
    php8.4-pgsql \
    php8.4-sqlite3 \
    php-imagick && \
  echo "**** install dokuwiki ****" && \
  curl -o \
  /tmp/dokuwiki.tar.gz -L \
    "https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${VERSION}.tgz" && \
  mkdir -p \
    /app/www/public && \
  tar xf \
    /tmp/dokuwiki.tar.gz -C \
    /app/www/public --strip-components=1 && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove \
    build-essential && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
