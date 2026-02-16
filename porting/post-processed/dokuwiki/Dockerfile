
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174

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
    php8.3-bz2 \
    php8.3-dom \
    php8.3-gd \
    php8.3-ldap \
    php8.3-mysql \
    php8.3-pgsql \
    php8.3-sqlite3 \
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
