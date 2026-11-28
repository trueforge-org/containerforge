FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG SHAARLI_SHA256=""
USER root

RUN apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates curl unzip && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: no upstream checksum is published. SHAARLI_SHA256 must come from a verified first download.
# The build fails while it is unset.
RUN set -eux; \
  test -n "${SHAARLI_SHA256}" || { echo "SHAARLI_SHA256 is not set" >&2; exit 1; }; \
  curl -fsSL -o /tmp/shaarli.zip "https://github.com/shaarli/Shaarli/releases/download/v${VERSION}/shaarli-v${VERSION}-full.zip"; \
  echo "${SHAARLI_SHA256}  /tmp/shaarli.zip" | sha256sum -c -; \
  unzip -q /tmp/shaarli.zip -d /tmp/src; \
  test -f /tmp/src/shaarli/index.php; \
  test -f /tmp/src/shaarli/vendor/autoload.php

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root
ENV TMPDIR=/tmp

# UNVERIFIED: every php8.5 extension in the upstream list must exist on ubuntu 26.04 (plan section 10).
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    php8.5-fpm \
    php8.5-cli \
    php8.5-curl \
    php8.5-gd \
    php8.5-intl \
    php8.5-ldap \
    php8.5-mbstring \
    php8.5-xml \
    php8.5-zip \
    php8.5-gettext && \
  rm -rf /var/lib/apt/lists/*

# php-fpm: the main config's pid and error log must be writable as apps. The pool is replaced below.
# UNVERIFIED: the error_log target (plan section 10).
RUN sed -i -E 's|^;?pid = .*|pid = /tmp/php-fpm.pid|; s|^;?error_log = .*|error_log = /proc/self/fd/2|' /etc/php/8.5/fpm/php-fpm.conf

COPY defaults/php-fpm/www.conf /etc/php/8.5/fpm/pool.d/www.conf
COPY defaults/nginx/nginx.conf /etc/nginx/nginx.conf

COPY --from=build /tmp/src/shaarli /app/shaarli
COPY --from=build /tmp/src/shaarli/COPYING /usr/share/licenses/shaarli/COPYING

# Shaarli writes config, bookmarks and cache under /config through these symlinks.
# They dangle until start.sh creates the targets.
RUN rm -rf /app/shaarli/data /app/shaarli/cache /app/shaarli/pagecache /app/shaarli/tmp && \
  ln -s /config/data /app/shaarli/data && \
  ln -s /config/cache /app/shaarli/cache && \
  ln -s /config/pagecache /app/shaarli/pagecache && \
  ln -s /config/tmp /app/shaarli/tmp && \
  chown -R apps:apps /app/shaarli && \
  chmod -R 755 /app/shaarli

USER apps
COPY --chmod=0755 . /

WORKDIR /app/shaarli
EXPOSE 8080
VOLUME /config
