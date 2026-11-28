
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# php8.5-redis and the other package names are UNVERIFIED on 26.04; check with `php -m` on first build
RUN echo "*** Installing runtime packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    php8.5-fpm \
    php8.5-cli \
    php8.5-curl \
    php8.5-gettext \
    php8.5-mbstring \
    php8.5-redis \
    php8.5-sqlite3 \
    php8.5-xml \
    php8.5-zip \
    redis-server && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Installing Barcode Buddy ***" && \
  mkdir -p /app/bbuddy && \
  curl -fL -o \
    /tmp/barcodebuddy.tar.gz \
    "https://github.com/Forceu/barcodebuddy/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/barcodebuddy.tar.gz -C \
    /app/bbuddy --strip-components=1 && \
  echo "*** Applying docker-mode settings (UNVERIFIED sed patterns, check against the files) ***" && \
  sed -i -E 's/(IS_DOCKER[[:space:]]*=[[:space:]]*)false/\1true/' /app/bbuddy/config-dist.php && \
  sed -i -E 's/(DEFAULT_USE_REDIS[^=]*=[[:space:]]*)["'\'']?0["'\'']?/\1"1"/' /app/bbuddy/incl/db.inc.php && \
  echo "*** Relocating nginx state to /tmp and loading rendered server config ***" && \
  rm -f /etc/nginx/sites-enabled/default && \
  sed -i \
    -e 's#^\([[:space:]]*\)pid .*#\1pid /tmp/nginx.pid;#' \
    -e 's#^\([[:space:]]*\)error_log .*#\1error_log /dev/stderr;#' \
    -e 's#^\([[:space:]]*\)access_log .*#\1access_log /dev/stdout;#' \
    -e 's#/etc/nginx/conf.d/\*\.conf#/tmp/nginx-conf.d/*.conf#' \
    -e '/^http {/a\    client_body_temp_path /tmp/nginx/client_body;\n    proxy_temp_path /tmp/nginx/proxy;\n    fastcgi_temp_path /tmp/nginx/fastcgi;\n    scgi_temp_path /tmp/nginx/scgi;\n    uwsgi_temp_path /tmp/nginx/uwsgi;' \
    /etc/nginx/nginx.conf && \
  echo "*** Creating data link and license ***" && \
  ln -s /config /data && \
  mkdir -p /usr/share/licenses/barcodebuddy && \
  cp /app/bbuddy/LICENSE.md /usr/share/licenses/barcodebuddy/LICENSE && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -f /tmp/barcodebuddy.tar.gz

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /config
