FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
# sha256 of the v${VERSION} source tarball, fetched 2026-11-27 (re-check at build)
ARG HUMHUB_SHA256=2f585748341958cb4ca75f40c72cba71fffa88cce7e9d10b971903c54836dbb1
USER root

# Build tools run on the ubuntu base: composer for PHP dependencies, node for the grunt asset build.
# UNVERIFIED: the ubuntu node/npm packages are suitable for grunt; the python-node base cannot provide composer.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        composer \
        nodejs \
        npm \
        php8.5-cli \
        php8.5-curl \
        php8.5-gd \
        php8.5-intl \
        php8.5-mbstring \
        php8.5-mysql \
        php8.5-xml \
        php8.5-zip && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/humhub.tar.gz "https://github.com/humhub/humhub/archive/v${VERSION}.tar.gz" && \
    echo "${HUMHUB_SHA256}  /tmp/humhub.tar.gz" | sha256sum -c - && \
    mkdir -p /build/humhub && \
    tar xzf /tmp/humhub.tar.gz -C /build/humhub --strip-components=1

# Mirrors the upstream builder stage (mriedmann/humhub-docker): composer, then grunt build-assets.
RUN cd /build/humhub && \
    composer install --no-dev --optimize-autoloader --no-scripts --no-interaction && \
    npm install grunt grunt-cli && \
    ./node_modules/.bin/grunt build-assets && \
    rm -rf /build/humhub/node_modules /tmp/* /root/.cache /root/.composer

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# PHP is set through php-fpm -d flags in defaults/supervisord.conf, and these ENV values are the defaults.
ENV \
  PHP_POST_MAX_SIZE=16M \
  PHP_UPLOAD_MAX_FILESIZE=10M \
  PHP_MAX_EXECUTION_TIME=60 \
  PHP_MEMORY_LIMIT=1G \
  PHP_TIMEZONE=UTC \
  HOME=/config

# Single container: php-fpm (FastCGI on 127.0.0.1:9000) and nginx (HTTP on 8080), run by supervisord.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        imagemagick \
        nginx \
        php8.5-cli \
        php8.5-curl \
        php8.5-fpm \
        php8.5-gd \
        php8.5-imagick \
        php8.5-intl \
        php8.5-mbstring \
        php8.5-mysql \
        php8.5-xml \
        php8.5-zip \
        supervisor && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /build/humhub /app/humhub

# Writable paths point at the persistent /config. UNVERIFIED: whether build-generated assets must be seeded into /config/assets.
# protected/config is the installer target, so an empty /config stays valid.
RUN rm -rf \
      /app/humhub/uploads \
      /app/humhub/assets \
      /app/humhub/themes \
      /app/humhub/protected/config \
      /app/humhub/protected/modules \
      /app/humhub/protected/runtime && \
    ln -s /config/uploads /app/humhub/uploads && \
    ln -s /config/assets /app/humhub/assets && \
    ln -s /config/themes /app/humhub/themes && \
    ln -s /config/protected-config /app/humhub/protected/config && \
    ln -s /config/modules /app/humhub/protected/modules && \
    ln -s /config/runtime /app/humhub/protected/runtime && \
    chown -R root:root /app && \
    chmod -R 755 /app && \
    mkdir -p /config && \
    chown -R apps:apps /config

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /config
