
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        php8.5-xml \
        php8.5-intl \
        php8.5-fpm \
        php8.5-mysql \
        php8.5-pgsql \
        php8.5-sqlite3 \
        php8.5-common && \
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
        /etc/php/8.5/fpm/conf.d/00_opcache.ini && \
    echo "**** configure php-fpm to pass env vars ****" && \
    sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.5/fpm/pool.d/www.conf && \
    if ! grep -qxF 'clear_env = no' /etc/php/8.5/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.5/fpm/pool.d/www.conf; fi && \
    echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.5/fpm/php-fpm.conf && \
    echo "**** install heimdall ****" && \
    mkdir -p \
        /heimdall && \
    curl -o \
        /tmp/heimdall.tar.gz -L \
        "https://github.com/linuxserver/Heimdall/archive/v${VERSION}.tar.gz" && \
    mkdir -p \
        /app/www && \
    tar xf \
        /tmp/heimdall.tar.gz -C \
        /app/www --strip-components=1 && \
    cp /app/www/storage/app/searchproviders.yaml /app/www/storage/app/searchproviders.yaml.orig && \
    echo "**** link writable state to /config and /tmp ****" && \
    for i in \
        storage/app/public/avatars \
        storage/app/public/backgrounds \
        storage/app/public/icons \
        storage/logs \
        app/SupportedApps \
        database/app.sqlite \
        .env \
        storage/app/searchproviders.yaml; do \
        rm -rf "/app/www/${i}" && \
        ln -s "/config/www/$(basename "${i}")" "/app/www/${i}"; \
    done && \
    rm -rf /app/www/storage/framework /app/www/bootstrap/cache && \
    ln -s /tmp/heimdall/framework /app/www/storage/framework && \
    ln -s /tmp/heimdall/bootstrap-cache /app/www/bootstrap/cache && \
    chown -R apps:apps /app && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443
VOLUME /config

WORKDIR /config
