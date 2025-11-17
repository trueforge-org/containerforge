
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    fontconfig \
    mariadb-client \
    memcached \
    php84-dom \
    php84-exif \
    php84-gd \
    php84-ldap \
    php84-mysqlnd \
    php84-opcache \
    php84-pdo_mysql \
    php84-pecl-memcached \
    php84-tokenizer \
    qt5-qtbase \
    ttf-freefont && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php84/php-fpm.d/www.conf && \
  if ! grep -qxF 'clear_env = no' /etc/php84/php-fpm.d/www.conf; then echo 'clear_env = no' >> /etc/php84/php-fpm.d/www.conf; fi && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php84/php-fpm.conf && \
  echo "**** fetch bookstack ****" && \
  mkdir -p\
    /app/www && \
  curl -o \
    /tmp/bookstack.tar.gz -L \
    "https://github.com/BookStackApp/BookStack/archive/v${VERSION}.tar.gz" && \
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
    $HOME/.composer

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config
