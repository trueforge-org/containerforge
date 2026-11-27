# Initial draft from drafts/Docker Hub/medium/servas/plan.md (option 1: ubuntu + apt PHP-FPM + nginx). Not built yet.

# PHP stage: fetch the upstream source and install PHP dependencies with composer.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS php
ARG VERSION
# UNVERIFIED: PHP minor version. Check `apt-cache policy` on the base and pin it.
ARG PHP_VERSION=8.5
USER root
ENV COMPOSER_CACHE_DIR=/tmp/composer \
    COMPOSER_HOME=/tmp/composer-home

RUN echo "**** install php and composer ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        composer \
        curl \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip && \
    rm -rf /var/lib/apt/lists/*

RUN echo "**** download servas ****" && \
    mkdir -p /tmp/src && \
    curl -fL -o /tmp/servas.tar.gz \
        "https://github.com/beromir/Servas/archive/refs/tags/v${VERSION}.tar.gz" && \
    tar xzf /tmp/servas.tar.gz -C /tmp/src --strip-components=1 && \
    rm -f /tmp/servas.tar.gz
# UNVERIFIED: upstream publishes no checksum. Pin the sha256 of the archive after computing it once.

RUN echo "**** install composer dependencies ****" && \
    cd /tmp/src && \
    composer install --no-dev --optimize-autoloader --no-plugins --no-scripts --no-interaction && \
    composer dump-autoload --no-dev --classmap-authoritative && \
    rm -rf /tmp/composer /tmp/composer-home
# UNVERIFIED: --no-scripts skips Laravel package discovery. Check at runtime whether `package:discover` must run in start.sh.

# Assets stage: build the vite frontend on the ContainerForge Node runtime.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS assets
USER root
COPY --from=php /tmp/src /tmp/src
# UNVERIFIED: Node major in this base (upstream builds with Node 24).
RUN echo "**** build frontend assets ****" && \
    cd /tmp/src && \
    npm_config_cache=/tmp/npm npm install && \
    npm run build && \
    rm -rf /tmp/npm

# Final stage: ubuntu with PHP-FPM and nginx, running as apps.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
ARG VERSION
# UNVERIFIED: must match the PHP stage.
ARG PHP_VERSION=8.5
USER root

RUN echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        mariadb-client \
        nginx \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-zip \
        sqlite3 && \
    ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/local/bin/php-fpm && \
    rm -rf /var/lib/apt/lists/*

COPY --from=php /tmp/src/ /app/
COPY --from=assets /tmp/src/public/build /app/public/build
COPY --from=php /tmp/src/LICENSE /usr/share/licenses/servas/LICENSE

RUN echo "**** remap writable paths to /config and /tmp ****" && \
    rm -rf /app/docker /app/database/sqlite /app/storage && \
    mkdir -p /app/database /app/bootstrap/cache && \
    ln -s /config/database/sqlite /app/database/sqlite && \
    ln -s /config/storage /app/storage && \
    chown -R root:root /app && \
    chmod -R 755 /app && \
    rm -rf /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /

ENV HOME=/config

EXPOSE 8080
VOLUME /config
