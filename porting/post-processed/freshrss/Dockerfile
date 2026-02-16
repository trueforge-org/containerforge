
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y \
        php8.3-xml \
        php8.3-exif \
        php8.3-gmp \
        php8.3-intl \
        php8.3-mysql \
        php8.3-pgsql \
        php8.3-sqlite3 \
        sqlite3 && \
    echo "**** configure php-fpm to pass env vars ****" && \
    sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf && \
    if ! grep -qxF 'clear_env = no' /etc/php/8.3/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.3/fpm/pool.d/www.conf; fi && \
    echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.3/fpm/php-fpm.conf && \
    echo "**** install app ****" && \
    mkdir -p \
        /app/www && \
    curl -o \
        /tmp/freshrss.tar.gz -L \
        "https://github.com/FreshRSS/FreshRSS/archive/${VERSION}.tar.gz" && \
    tar xf \
        /tmp/freshrss.tar.gz -C \
        /app/www --strip-components=1 && \
    sed -i "s|'disable_update' => false,|'disable_update' => true,|g" \
        /app/www/config.default.php && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
