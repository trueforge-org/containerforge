# Initial draft from plan.md. Not built or tested.
# BLOCKER (plan section 3): upstream composer.json requires PHP ~7.4, which ubuntu 26.04 does not ship.
# The PHP runtime step below is a placeholder until that blocker is resolved. Do not guess a PHP 8 package set.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
# UNVERIFIED: no upstream checksum for 1.6.2.zip. Compute it, pin it here, and mark it self-computed (trust on first use).
ARG SHA256_CHEVERETO=""

USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      apache2 \
      ca-certificates \
      curl \
      unzip; \
    rm -rf /var/lib/apt/lists/*

# PLACEHOLDER (blocker): PHP 7.4 with the apache2 module and the extensions from the plan
# (curl, exif, fileinfo, gd, json, pdo_mysql, zip, opcache, imagick). Not provided yet.

RUN set -eux; \
    curl -fL -o /tmp/chevereto.zip "https://github.com/rodber/chevereto-free/releases/download/${VERSION}/${VERSION}.zip"; \
    echo "${SHA256_CHEVERETO}  /tmp/chevereto.zip" | sha256sum -c -; \
    mkdir -p /app/chevereto /usr/share/licenses/chevereto; \
    unzip -q /tmp/chevereto.zip -d /app/chevereto; \
    rm -f /app/chevereto/sync.sh; \
    cp /app/chevereto/LICENSE /usr/share/licenses/chevereto/LICENSE; \
    rm -f /tmp/chevereto.zip

# UNVERIFIED: composer install is not added yet. Upstream uses composer:latest (unpinned) and vendors into app/vendor.
# Planned: composer install --working-dir=/app/chevereto --no-dev --classmap-authoritative --ignore-platform-reqs
# COMPOSER_HOME and COMPOSER_CACHE_DIR must point to /tmp.

# Writable data lives in /config (plan section 9). Symlink the upstream VOLUME paths there.
RUN set -eux; \
    rm -rf /app/chevereto/content /app/chevereto/images; \
    ln -s /config/content /app/chevereto/content; \
    ln -s /config/images /app/chevereto/images

# Apache: listen on 8080 (non-root cannot bind 80), serve /app/chevereto, and move runtime paths to /tmp.
# UNVERIFIED: the exact apache2 default-site and envvars layout on ubuntu 26.04.
RUN set -eux; \
    sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf; \
    sed -i 's#<VirtualHost \*:80>#<VirtualHost *:8080>#; s#/var/www/html#/app/chevereto#g; s#/var/www/#/app/#g' /etc/apache2/sites-available/000-default.conf; \
    sed -i 's#/var/run/apache2#/tmp/apache#g; s#/var/lock/apache2#/tmp/apache#g; s#/var/log/apache2#/tmp/apache/log#g; s#APACHE_RUN_USER=www-data#APACHE_RUN_USER=apps#; s#APACHE_RUN_GROUP=www-data#APACHE_RUN_GROUP=apps#' /etc/apache2/envvars; \
    a2enmod rewrite

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
WORKDIR /config
