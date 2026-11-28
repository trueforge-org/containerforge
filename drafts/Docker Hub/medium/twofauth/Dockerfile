FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    composer \
    nginx \
    php8.5-bcmath \
    php8.5-cli \
    php8.5-curl \
    php8.5-fpm \
    php8.5-gd \
    php8.5-intl \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-pgsql \
    php8.5-redis \
    php8.5-sqlite3 \
    php8.5-xml \
    php8.5-zip \
    supervisor && \
  echo "**** fetch 2fauth ****" && \
  mkdir -p \
    /app/2fauth && \
  curl -fL -o \
    /tmp/2fauth.tar.gz \
    "https://github.com/Bubka/2FAuth/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/2fauth.tar.gz -C \
    /app/2fauth --strip-components=1 && \
  echo "**** install composer dependencies ****" && \
  COMPOSER_HOME=/tmp/composer COMPOSER_CACHE_DIR=/tmp/composer-cache \
    composer install -d /app/2fauth --no-dev --optimize-autoloader --no-interaction --no-scripts && \
  echo "**** move writable state to /config ****" && \
  mkdir -p /usr/share/twofauth && \
  cp -a /app/2fauth/storage /usr/share/twofauth/storage.pristine && \
  rm -rf /app/2fauth/storage && \
  ln -s /config/storage /app/2fauth/storage && \
  ln -s /config/storage/app/public /app/2fauth/public/storage && \
  rm -f /app/2fauth/.env && \
  ln -s /config/.env /app/2fauth/.env && \
  mkdir -p /usr/share/licenses/twofauth && \
  install -m 0644 /app/2fauth/LICENSE /usr/share/licenses/twofauth/LICENSE && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.composer && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

ENV LOG_CHANNEL=daily \
    LOG_LEVEL=info \
    DB_CONNECTION=sqlite \
    DB_DATABASE=/config/database/database.sqlite \
    WEBAUTHN_NAME=2FAuth \
    APP_CONFIG_CACHE=/tmp/bootstrap/config.php \
    APP_ROUTES_CACHE=/tmp/bootstrap/routes.php \
    APP_EVENTS_CACHE=/tmp/bootstrap/events.php \
    APP_SERVICES_CACHE=/tmp/bootstrap/services.php \
    APP_PACKAGES_CACHE=/tmp/bootstrap/packages.php

# ports and volumes
EXPOSE 8000
VOLUME /config

WORKDIR /config

CMD ["/start.sh"]
