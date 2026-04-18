FROM ghcr.io/trueforge-org/node:22.22.0@sha256:57a4a36bdf735ecfef262feb3354be695eadba8d4bd73138444dadfcce23da02

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        gnupg2 && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    echo "**** install yarn ****" && \
    npm install -g --omit=dev yarn@1.22.22 && \
    echo "**** install runtime packages ****" && \
    apt-get install -y --no-install-recommends \
        php8.5-common \
        php8.5-gd \
        php8.5-intl \
        php8.5-ldap \
        php8.5-fpm \
        composer \
        php8.5-xml \
        php8.5-sqlite3 && \
    echo "**** configure php-fpm to pass env vars ****" && \
    if [ -f /etc/php/8.5/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.5/fpm/pool.d/www.conf && grep -qxF 'clear_env = no' /etc/php/8.5/fpm/pool.d/www.conf || echo 'clear_env = no' >> /etc/php/8.5/fpm/pool.d/www.conf; fi && \
    echo "**** install grocy ****" && \
    mkdir -p /app/www && \
    if ! curl -fL -o \
        /tmp/grocy.tar.gz \
        "https://github.com/grocy/grocy/archive/refs/tags/v${VERSION}.tar.gz"; then \
        curl -fL -o \
            /tmp/grocy.tar.gz \
            "https://github.com/grocy/grocy/archive/refs/tags/${VERSION}.tar.gz"; \
    fi && \
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
        software-properties-common \
        gnupg2 && \
    apt-get autoremove -y && \
    rm -rf \
        /tmp/* \
        $HOME/.cache \
        $HOME/.composer && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
