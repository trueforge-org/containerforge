FROM ghcr.io/trueforge-org/node:24.15.0@sha256:5d401829d5061483016ca171db4e1d540fc07ba5e4b8722a3b5f272c2b69ffae

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    grep \
    composer \
    php8.5-curl \
    php8.5-gd \
    php8.5-intl \
    php8.5-mysql \
    php8.5-pgsql \
    php8.5-sqlite3 \
    php-redis \
    php8.5-xml \
    php8.5-zip \
    postgresql-client \
    ssmtp && \
  echo "*** install speedtest-cli ***" && \
  if [ -z ${CLI_VERSION+x} ]; then \
    CLI_VERSION=$(curl -fsSL https://packagecloud.io/ookla/speedtest-cli/debian/dists/bookworm/main/binary-$TARGETARCH/Packages \
    | sed -n '/Package: speedtest/,/Homepage:/p' \
    | grep -oP 'Version: \K\S+' | cut -d. -f1-3 | head -n1); \
  fi && \
  case "$TARGETARCH" in amd64) CLI_ARCH=x86_64 ;; arm64) CLI_ARCH=aarch64 ;; *) CLI_ARCH="$TARGETARCH" ;; esac && \
  curl -fL -o \
    /tmp/speedtest-cli.tgz \
    "https://install.speedtest.net/app/cli/ookla-speedtest-${CLI_VERSION}-linux-${CLI_ARCH}.tgz" && \
  tar xzf \
    /tmp/speedtest-cli.tgz -C \
    /usr/bin && \
  echo "**** configure php-fpm to pass env vars ****" && \
  if [ -f /etc/php/8.5/fpm/pool.d/www.conf ]; then sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php/8.5/fpm/pool.d/www.conf && if ! grep -qxF 'clear_env = no' /etc/php/8.5/fpm/pool.d/www.conf; then echo 'clear_env = no' >> /etc/php/8.5/fpm/pool.d/www.conf; fi && echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php/8.5/fpm/php-fpm.conf; fi && \
  echo "*** install speedtest-tracker ***" && \
  curl -o \
    /tmp/speedtest-tracker.tar.gz -L \
    "https://github.com/alexjustesen/speedtest-tracker/archive/v${VERSION}.tar.gz" && \
  mkdir -p /app/www && \
  tar xzf \
    /tmp/speedtest-tracker.tar.gz -C \
    /app/www/ --strip-components=1 && \
  cd /app/www && \
  composer install \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-dev \
    --no-cache && \
  npm ci && npm run build && \
  echo "**** setup php opcache ****" && \
  mkdir -p /etc/php/8.5/cli/conf.d && \
  { \
    echo 'opcache.enable_cli=1'; \
  } > /etc/php/8.5/cli/conf.d/opcache-recommended.ini; \
  { \
    echo 'post_max_size = 100M'; \
    echo 'upload_max_filesize = 100M'; \
    echo 'variables_order = EGPCS'; \
  } > /etc/php/8.5/cli/conf.d/php-misc.ini && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.cache \
    $HOME/.npm \
    /app/www/node_modules \
    /tmp/*

USER apps
COPY --chmod=0755 . /


VOLUME /config

WORKDIR /config
