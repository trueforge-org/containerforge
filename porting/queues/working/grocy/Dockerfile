FROM ghcr.io/trueforge-org/node:22.22.0

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        yarn && \
    echo "**** install runtime packages ****" && \
    apt-get install -y --no-install-recommends \
        php8.3-gd \
        php8.3-intl \
        php8.3-ldap \
        php8.3-opcache \
        composer \
        php8.3-xml \
        php8.3-sqlite3 \
        php8.3-tokenizer && \
    echo "**** configure php-fpm to pass env vars ****" && \
    if [ -f /etc/php/8.3/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf && grep -qxF 'clear_env = no' /etc/php/8.3/fpm/pool.d/www.conf || echo 'clear_env = no' >> /etc/php/8.3/fpm/pool.d/www.conf; fi && \
    echo "**** install grocy ****" && \
    mkdir -p /app/www && \
    curl -fL -o \
        /tmp/grocy.tar.gz \
        "https://github.com/grocy/grocy/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
        /tmp/grocy.tar.gz \
        "https://github.com/grocy/grocy/archive/refs/tags/${VERSION}.tar.gz" && \
    tar xf \
        /tmp/grocy.tar.gz -C \
        /app/www/ --strip-components=1 && \
    chown -R apps:apps /app && \
    mkdir -p /defaults/plugins && \
    cp -R /app/www/data/plugins \
        /defaults/plugins && \
    echo "**** install composer packages ****" && \
    composer install -d /app/www --no-dev && \
    echo "**** install yarn packages ****" && \
    cd /app/www && \
    yarn --production && \
    yarn cache clean && \
    echo "**** cleanup ****" && \
    apt-get remove -y --purge \
        yarn && \
    apt-get autoremove -y && \
    rm -rf \
        /tmp/* \
        $HOME/.cache \
        $HOME/.composer && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
