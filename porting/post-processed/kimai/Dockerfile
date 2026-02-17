
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        php8.3-gd \
        php8.3-intl \
        php8.3-ldap \
        php8.3-mysql \
        composer \
        php-redis \
        php8.3-zip \
        php8.3-xml && \
    rm -rf /var/lib/apt/lists/* && \
    echo "**** configure php-fpm to pass env vars ****" && \
    if [ -f /etc/php/8.3/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php/8.3/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.3/fpm/pool.d/www.conf; fi && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.3/fpm/php-fpm.conf; fi && \
    echo "**** install kimai ****" && \
    mkdir -p\
        /app/www && \
    curl -fL -o \
        /tmp/kimai.tar.gz \
        "https://github.com/kimai/kimai/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
        /tmp/kimai.tar.gz \
        "https://github.com/kimai/kimai/archive/refs/tags/v${VERSION}.tar.gz" && \
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
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
