
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:17312da6b52fe7ab6e3bdc8e4a1f99df63c2494b2bad4f4b634a9065d585898e

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    libxml2-16 \
    mariadb-client \
    php8.5-bcmath \
    php8.5-curl \
    php8.5-gd \
    php8.5-ldap \
    php8.5-mysql \
    php8.5-sqlite3 \
    php-redis \
    composer \
    php8.5-common \
    php8.5-cli \
    php8.5-xml \
    php8.5-zip \
    php-mcrypt && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php85/php-fpm.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php85/php-fpm.d/www.conf && grep -qxF 'clear_env = no' /etc/php85/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php85/php-fpm.d/www.conf && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php85/php-fpm.conf; fi && \
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
  composer install --no-dev --ignore-platform-req=php -d /app/www && \
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
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443

VOLUME /config

WORKDIR /config
