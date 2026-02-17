
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        php8.3-xml \
        php8.3-intl \
        php8.3-opcache \
        php8.3-fpm \
        php8.3-mysql \
        php8.3-pgsql \
        php8.3-sqlite3 \
        php8.3-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "**** configure nginx ****" && \
    mkdir -p /etc/nginx && \
    touch /etc/nginx/fastcgi_params && \
    echo 'fastcgi_param  PHP_AUTH_USER      $remote_user; # Heimdall user authorization' >> \
        /etc/nginx/fastcgi_params && \
    echo 'fastcgi_param  PHP_AUTH_PW        $http_authorization; # Heimdall user authorization' >> \
        /etc/nginx/fastcgi_params && \
    echo "**** configure php opcache ****" && \
    echo 'opcache.validate_timestamps=0' >> \
        /etc/php/8.3/fpm/conf.d/00_opcache.ini && \
    echo "**** configure php-fpm to pass env vars ****" && \
    sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.3/fpm/pool.d/www.conf && \
    if ! grep -qxF 'clear_env = no' /etc/php/8.3/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.3/fpm/pool.d/www.conf; fi && \
    echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.3/fpm/php-fpm.conf && \
    echo "**** install heimdall ****" && \
    mkdir -p \
        /heimdall && \
    curl -o \
        /tmp/heimdall.tar.gz -L \
        "https://github.com/linuxserver/Heimdall/archive/v${VERSION}.tar.gz" && \
    mkdir -p \
        /app/www-tmp && \
    tar xf \
        /tmp/heimdall.tar.gz -C \
        /app/www-tmp --strip-components=1 && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/*

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
