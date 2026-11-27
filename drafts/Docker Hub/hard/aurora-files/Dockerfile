# Base digest matches the sibling apps (bookstack, kasmvnc); plan.md recorded 19cb... for the same tag.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: PHP 8.5 support in Aurora Files 9.8.7 (upstream tests on php 8.3). php8.5-exif is not listed:
# exif is a separate package upstream, check it in the 26.04 archive before adding it.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    mariadb-client \
    nginx \
    php8.5-cli \
    php8.5-curl \
    php8.5-fpm \
    php8.5-gd \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-sqlite3 \
    php8.5-xml \
    php8.5-zip \
    unzip && \
  echo "**** fetch aurora-files ****" && \
  curl -fL -o /tmp/aurora-files.zip \
    https://afterlogic.org/download/aurora-files.zip && \
  mkdir -p /app/www && \
  unzip -q /tmp/aurora-files.zip -d /app/www && \
  echo "**** check version ****" && \
  grep -q "^${VERSION}" /app/www/VERSION && \
  echo "**** move writable data out of /app ****" && \
  rm -rf /app/www/data && \
  ln -s /config/data /app/www/data && \
  echo "**** licence ****" && \
  mkdir -p /usr/share/licenses/aurora-files && \
  cp /app/www/LICENSE /usr/share/licenses/aurora-files/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# php settings go into the fpm and cli conf.d (root-owned, so done before USER apps)
COPY --chmod=0644 etc/php/aurora.ini /etc/php/8.5/fpm/conf.d/99-aurora.ini
COPY --chmod=0644 etc/php/aurora.ini /etc/php/8.5/cli/conf.d/99-aurora.ini

USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
