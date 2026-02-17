
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    fontconfig \
    mariadb-client \
    memcached \
    php8.3-xml \
    php8.3-curl \
    php8.3-exif \
    php8.3-gd \
    php8.3-ldap \
    php8.3-mysql \
    php8.3-opcache \
    php8.3-memcached \
    php8.3-tokenizer \
    php8.3-zip \
    composer \
    qtbase5-dev \
    fonts-freefont-ttf && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php/8.3/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php/8.3/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.3/fpm/pool.d/www.conf; fi && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.3/fpm/php-fpm.conf; fi && \
  echo "**** fetch bookstack ****" && \
  mkdir -p\
    /app/www && \
  curl -fL -o \
    /tmp/bookstack.tar.gz \
    "https://github.com/BookStackApp/BookStack/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
    /tmp/bookstack.tar.gz \
    "https://github.com/BookStackApp/BookStack/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/bookstack.tar.gz -C \
    /app/www/ --strip-components=1 && \
  echo "**** install composer dependencies ****" && \
  composer install -d /app/www/ && \
  echo "**** create symlinks ****" && \
  /bin/bash -c \
  'dst=(www/themes www/files www/images www/uploads backups www/framework/cache www/framework/sessions www/framework/views log/bookstack/laravel.log www/.env); \
  src=(themes storage/uploads/files storage/uploads/images public/uploads storage/backups storage/framework/cache storage/framework/sessions storage/framework/views storage/logs/laravel.log .env); \
  for i in "${!src[@]}"; do rm -rf /app/www/"${src[i]}" && ln -s /config/"${dst[i]}" /app/www/"${src[i]}"; done' && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.composer && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
