FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG APP_VERSION
USER root

ENV \
  HOME=/config \
  COMPOSER_HOME=/tmp/composer \
  COMPOSER_CACHE_DIR=/tmp/composer-cache \
  COMPOSER_ALLOW_SUPERUSER=1

# UNVERIFIED: php8.5 package names and the PHP 8.5 / Laravel 12 / Mixpost compatibility are not tested.
RUN echo "*** Installing PHP, nginx and ffmpeg ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    php8.5-cli \
    php8.5-fpm \
    php8.5-mysql \
    php8.5-redis \
    php8.5-curl \
    php8.5-mbstring \
    php8.5-xml \
    php8.5-zip \
    php8.5-gd \
    php8.5-bcmath \
    php8.5-intl \
    ffmpeg \
    nginx \
    composer \
    unzip \
    git \
    ca-certificates && \
  rm -rf /var/lib/apt/lists/*

# The skeleton is versioned separately (APP_VERSION) from the package (VERSION). Both come from docker-bake.hcl.
# UNVERIFIED: create-project runs key:generate, which writes .env. The .env is removed below so no key is baked in.
RUN echo "*** Creating Mixpost app ${APP_VERSION} with package ${VERSION} ***" && \
  composer create-project --no-dev --no-interaction inovector/mixpostapp:${APP_VERSION} /app/www && \
  cd /app/www && \
  composer require --no-interaction -W inovector/mixpost:${VERSION} && \
  rm -f /app/www/.env && \
  php artisan vendor:publish --tag=mixpost-assets --force && \
  echo "*** Linking writable paths to /config and /tmp ***" && \
  cd /app/www && \
  rm -rf storage/app storage/logs storage/framework bootstrap/cache && \
  ln -s /config/storage/app storage/app && \
  ln -s /config/storage/logs storage/logs && \
  ln -s /tmp/storage-framework storage/framework && \
  ln -s /tmp/bootstrap-cache bootstrap/cache && \
  # UNVERIFIED: Laravel public disk link. Created at build time because /app is read-only at runtime.
  ln -s /config/storage/app/public public/storage && \
  echo "*** Installing licenses ***" && \
  mkdir -p /usr/share/licenses/mixpost && \
  cp /app/www/vendor/inovector/mixpost/LICENSE.md /usr/share/licenses/mixpost/LICENSE.md && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && \
  rm -rf /tmp/* /root/.cache

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
