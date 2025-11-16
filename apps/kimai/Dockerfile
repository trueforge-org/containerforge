
FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.22

# set version label
ARG VERSION

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    php84-gd \
    php84-intl \
    php84-ldap \
    php84-pdo_mysql \
    php84-pecl-redis \
    php84-tokenizer \
    php84-xmlreader \
    php84-xsl && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php84/php-fpm.d/www.conf && \
  if ! grep -qxF 'clear_env = no' /etc/php84/php-fpm.d/www.conf; then echo 'clear_env = no' >> /etc/php84/php-fpm.d/www.conf; fi && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php84/php-fpm.conf && \
  echo "**** install kimai ****" && \
  mkdir -p\
    /app/www && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/kimai/kimai/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/kimai.tar.gz -L \
    "https://github.com/kimai/kimai/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/kimai.tar.gz -C \
    /app/www --strip-components=1 && \
  echo "**** install composer dependencies ****" && \
  COMPOSER_MEMORY_LIMIT=-1 php -d memory_limit=-1 /usr/bin/composer install -d /app/www/ --no-dev --optimize-autoloader --no-interaction && \
  COMPOSER_MEMORY_LIMIT=-1 php -d memory_limit=-1 /usr/bin/composer require -d /app/www/ --update-no-dev laminas/laminas-ldap && \
  /usr/bin/composer clearcache -d /app/www/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.composer

# add local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config
