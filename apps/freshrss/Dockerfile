
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:e566b6c11ab30372ddb0ee460a2f65699fd50ad2eb148ddac0d7800074159f19

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y \
        php8.5-cli \
        php8.5-xml \
        php8.5-gmp \
        php8.5-intl \
        php8.5-mysql \
        php8.5-pgsql \
        php8.5-sqlite3 \
        sqlite3 && \
    echo "**** configure php-fpm to pass env vars ****" && \
    if [ -f /etc/php/8.5/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.5/fpm/pool.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php/8.5/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.5/fpm/pool.d/www.conf; fi && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.5/fpm/php-fpm.conf; fi && \
    echo "**** install app ****" && \
    mkdir -p \
        /app/www && \
    curl -fL -o \
        /tmp/freshrss.tar.gz \
        "https://github.com/FreshRSS/FreshRSS/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o \
        /tmp/freshrss.tar.gz \
        "https://github.com/FreshRSS/FreshRSS/archive/refs/tags/v${VERSION}.tar.gz" && \
    tar xf \
        /tmp/freshrss.tar.gz -C \
        /app/www --strip-components=1 && \
    mv /app/www/data /app/www/data.bak && \
    mv /app/www/extensions /app/www/extensions.bak && \
    ln -s /config/www/freshrss/data /app/www/data && \
    ln -s /config/www/freshrss/extensions /app/www/extensions && \
    chown -R apps:apps /app && \
    sed -i "s|'disable_update' => false,|'disable_update' => true,|g" \
        /app/www/config.default.php && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
