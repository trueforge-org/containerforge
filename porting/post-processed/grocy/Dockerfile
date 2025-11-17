## TODO: pin versionn tag
FROM ghcr.io/trueforge-org/node:rolling@sha256:56c028d92c9c7e5d29c1265fd0b615c9fbc4995cf5f6ef6007393c3030b4b749

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    yarn && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    php83-gd \
    php83-intl \
    php83-ldap \
    php83-opcache \
    php83-pdo \
    php83-pdo_sqlite \
    php83-tokenizer && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && \
  grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && \
  echo "**** install grocy ****" && \
  mkdir -p /app/www && \
  curl -o \
    /tmp/grocy.tar.gz -L \
    "https://github.com/grocy/grocy/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/grocy.tar.gz -C \
    /app/www/ --strip-components=1 && \
  cp -R /app/www/data/plugins \
    /defaults/plugins && \
  echo "**** install composer packages ****" && \
  composer install -d /app/www --no-dev && \
  echo "**** install yarn packages ****" && \
  cd /app/www && \
  yarn --production && \
  yarn cache clean && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
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
