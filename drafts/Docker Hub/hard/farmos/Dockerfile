
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  COMPOSER_HOME=/tmp/composer \
  COMPOSER_MEMORY_LIMIT=-1 \
  COMPOSER_ALLOW_SUPERUSER=1

# UNVERIFIED on 26.04: php-geos must provide the geos extension for PHP 8.5, and the PHP 8.5 build
# must satisfy Drupal 10.6 (see plan section 10). Check with `php -m` in the build.
RUN echo "*** Installing PHP, nginx and build tools ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    composer \
    git \
    nginx \
    php-geos \
    php8.5-bcmath \
    php8.5-cli \
    php8.5-curl \
    php8.5-fpm \
    php8.5-gd \
    php8.5-intl \
    php8.5-mbstring \
    php8.5-opcache \
    php8.5-pgsql \
    php8.5-xml \
    php8.5-zip \
    postgresql-client \
    unzip && \
  php -m | grep -E '^(bcmath|geos|gd|pdo_pgsql)$' && \
  rm -rf /var/lib/apt/lists/*

# Same method as upstream build-farmOS.sh: composer-project (branch 3.x) requires farmos/farmos at the tag.
# Plugin list copied from upstream. Note: 3.x is a floating branch, so consider pinning a commit.
RUN echo "*** Building farmOS ${VERSION} ***" && \
  git clone --depth 1 --branch 3.x https://github.com/farmOS/composer-project.git /app/farmos && \
  cd /app/farmos && \
  for p in \
    composer/installers \
    cweagans/composer-patches \
    dealerdirect/phpcodesniffer-composer-installer \
    drupal/core-composer-scaffold \
    oomphinc/composer-installers-extender \
    phpstan/extension-installer \
    wikimedia/composer-merge-plugin; do \
    composer config --no-plugins "allow-plugins.${p}" true; \
  done && \
  composer require "farmos/farmos:${VERSION}" --no-install && \
  composer install --no-dev --no-interaction && \
  sed -i "s|version: 3.x|version: ${VERSION}|g" web/profiles/farm/farm.info.yml && \
  echo "*** Moving the default sites directory out of the way so /config can hold it ***" && \
  mv /app/farmos/web/sites /app/farmos-sites-default && \
  ln -s /config/sites /app/farmos/web/sites && \
  rm -rf /app/farmos/.git

RUN echo "*** Installing licenses ***" && \
  mkdir -p /usr/share/licenses/farmos && \
  curl -fsSL -o /usr/share/licenses/farmos/LICENSE.txt \
    "https://raw.githubusercontent.com/farmOS/farmOS/${VERSION}/LICENSE.txt" && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/composer /var/cache/apt/archives/*.deb

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /app/farmos
