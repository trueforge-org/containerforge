# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# UNVERIFIED: PHP 8.5 package names on 26.04 (same family as apps/bookstack), confirm with apt-cache policy.
RUN echo "*** Installing nginx and PHP ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    php8.5-fpm \
    php8.5-cli \
    php8.5-curl \
    php8.5-xml \
    php8.5-gd \
    php8.5-zip \
    php8.5-mbstring \
    php8.5-intl \
    php8.5-pgsql \
    php8.5-mysql \
    php8.5-sqlite3 && \
  rm -rf /var/lib/apt/lists/*

# No checksum is published for the source tarball. The tag is pinned instead.
RUN echo "*** Installing Spotweb ${VERSION} ***" && \
  curl -fsSL -o /tmp/spotweb.tgz \
    "https://github.com/spotweb/spotweb/archive/refs/tags/${VERSION}.tar.gz" && \
  mkdir -p /app/www && \
  tar xzf /tmp/spotweb.tgz -C /app/www --strip-components=1 && \
  ln -s /config/dbsettings.inc.php /app/www/dbsettings.inc.php && \
  ln -s /config/ownsettings.php /app/www/ownsettings.php && \
  ln -s /tmp/spotweb-cache /app/www/cache && \
  mkdir -p /usr/share/licenses/spotweb && \
  cp /app/www/LICENSE.md /usr/share/licenses/spotweb/ && \
  rm -f /tmp/spotweb.tgz

ENV \
  HOME=/config \
  XDG_CACHE_HOME=/tmp/.cache

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
WORKDIR /app/www
