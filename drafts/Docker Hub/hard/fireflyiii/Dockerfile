
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

# Firefly III 6.x needs PHP >= 8.5. UNVERIFIED: every php8.5-* package below is available on 26.04.
# php-fpm and nginx run in one container; start.sh starts both (no s6 here).
RUN echo "*** Installing nginx, PHP-FPM and extensions ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    netcat-openbsd \
    php8.5-fpm \
    php8.5-cli \
    php8.5-bcmath \
    php8.5-curl \
    php8.5-gd \
    php8.5-intl \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-pgsql \
    php8.5-redis \
    php8.5-sqlite3 \
    php8.5-xml \
    php8.5-zip && \
  rm -rf /var/lib/apt/lists/*

ENV \
  HOME=/config \
  PHP_INI_SCAN_DIR=:/tmp/php.d

# The release tarball has a .sha256 file next to it. The format is "<sha256> *<file>", and only the first field is used.
# UNVERIFIED: whether the archive has a top-level directory. The assertion below fails the build if the layout differs.
RUN echo "*** Installing Firefly III ${VERSION} ***" && \
  curl -fL -o \
    /tmp/firefly-iii.tar.gz \
    "https://github.com/firefly-iii/firefly-iii/releases/download/v${VERSION}/FireflyIII-v${VERSION}.tar.gz" && \
  curl -fL -o \
    /tmp/firefly-iii.sha256 \
    "https://github.com/firefly-iii/firefly-iii/releases/download/v${VERSION}/FireflyIII-v${VERSION}.tar.gz.sha256" && \
  echo "$(cut -d' ' -f1 /tmp/firefly-iii.sha256)  /tmp/firefly-iii.tar.gz" | sha256sum -c - && \
  mkdir -p /app/www && \
  tar xzf \
    /tmp/firefly-iii.tar.gz -C \
    /app/www && \
  test -f /app/www/artisan && \
  test -f /app/www/public/index.php && \
  mkdir -p /usr/share/licenses/fireflyiii && \
  cp /app/www/LICENSE /usr/share/licenses/fireflyiii/LICENSE && \
  rm -rf /app/www/storage /app/www/bootstrap/cache && \
  ln -s /config/storage /app/www/storage && \
  ln -s /tmp/bootstrap-cache /app/www/bootstrap/cache && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -f /tmp/firefly-iii.tar.gz /tmp/firefly-iii.sha256 && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /app/www
EXPOSE 8080

VOLUME /config
