
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libxml2 \
    mariadb-client \
    php8.3-bcmath \
    php8.3-curl \
    php8.3-exif \
    php8.3-gd \
    php8.3-ldap \
    php8.3-mysql \
    php8.3-sqlite3 \
    php-redis \
    composer \
    php8.3-common \
    php8.3-xml \
    php8.3-zip \
    php-mcrypt && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php83/php-fpm.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf; fi && \
  echo "**** install snipe-it ****" && \
  mkdir -p \
    /app/www/ && \
  curl -o \
    /tmp/snipeit.tar.gz -L \
    "https://github.com/grokability/snipe-it/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/snipeit.tar.gz -C \
    /app/www/ --strip-components=1 && \
  cp /app/www/docker/docker.env /app/www/.env && \
  composer install --no-dev -d /app/www && \
  echo "**** move storage directories to defaults ****" && \
  mkdir -p /defaults && \
  mv \
    "/app/www/storage" \
    "/app/www/public/uploads" \
    /defaults/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    $HOME/.cache \
    $HOME/.composer \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443

VOLUME /config

WORKDIR /config
