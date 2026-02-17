
FROM ghcr.io/trueforge-org/ubuntu:24.04

ARG VERSION
ARG TARGETARCH
USER root

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        busybox \
        libnginx-mod-http-brotli-filter libnginx-mod-http-brotli-static \
        php8.3-fpm \
        php8.3-common \
        php8.3-xml \
        php8.3-gd \
        php8.3-intl \
        php8.3-ldap \
        php8.3-opcache \
        php8.3-sqlite3 \
        php8.3-apcu \
        php8.3-yaml \
        php8.3-redis && \
    rm -rf /var/lib/apt/lists/* && \
    echo "**** configure php-fpm to pass env vars ****" && \
    if [ -f /etc/php83/php-fpm.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf; fi && \
    echo "**** setup php opcache ****" && \
    mkdir -p /etc/php83/conf.d && \
    { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=2'; \
        echo 'opcache.enable_cli=1'; \
    } > /etc/php83/conf.d/php-opcache.ini && \
    echo "*** Installing Grav ***" && \
    mkdir -p \
        /app/www/public && \
    curl -o \
        /tmp/grav.zip -L \
        "https://github.com/getgrav/grav/releases/download/${VERSION}/grav-admin-v${VERSION}.zip" && \
    unzip -q \
        /tmp/grav.zip -d /tmp/grav && \
    mv /tmp/grav/grav-admin/* /app/www/public/ && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        $HOME/.cache \
        $HOME/.composer

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443

VOLUME /config

WORKDIR /config
