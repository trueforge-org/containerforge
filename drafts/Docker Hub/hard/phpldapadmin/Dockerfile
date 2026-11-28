FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

USER root

# UNVERIFIED: package list follows apps/bookstack (php8.5 on ubuntu 26.04); confirm php8.5-ldap,
# and which packages are strictly needed. php8.5-memcached is only for CACHE_DRIVER=memcached.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        composer \
        curl \
        nginx \
        php8.5-cli \
        php8.5-curl \
        php8.5-fpm \
        php8.5-ldap \
        php8.5-mbstring \
        php8.5-memcached \
        php8.5-xml \
        php8.5-zip \
        unzip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# phpLDAPadmin v2 from the source tag (no release assets, no published checksum).
# UNVERIFIED: LICENSE is GPL-2.0 per the repo file, composer.json says MIT (see docker-bake.hcl).
RUN mkdir -p /app/www \
    && curl -fL -o /tmp/pla.tar.gz "https://github.com/leenooks/phpLDAPadmin/archive/refs/tags/${VERSION}.tar.gz" \
    && tar xzf /tmp/pla.tar.gz -C /app/www --strip-components=1 \
    && rm -f /tmp/pla.tar.gz \
    && cd /app/www \
    && COMPOSER_HOME=/tmp/composer composer install --no-dev --optimize-autoloader --no-interaction \
    && mkdir -p /usr/share/licenses/phpldapadmin \
    && cp /app/www/LICENSE /usr/share/licenses/phpldapadmin/ \
    && rm -rf /tmp/composer /tmp/*

# Laravel writes go to /tmp (ephemeral); start.sh creates the targets on every start.
RUN cd /app/www \
    && rm -rf storage/framework/sessions storage/framework/cache storage/framework/views storage/logs bootstrap/cache \
    && mkdir -p storage/framework \
    && ln -s /tmp/pla/sessions storage/framework/sessions \
    && ln -s /tmp/pla/cache storage/framework/cache \
    && ln -s /tmp/pla/views storage/framework/views \
    && ln -s /tmp/pla/logs storage/logs \
    && ln -s /tmp/pla/bootstrap bootstrap/cache

ENV HOME=/config

# Copy configuration files and start.sh into container
COPY --chmod=0755 . /

USER apps

EXPOSE 8080
VOLUME /config

CMD ["/start.sh"]
