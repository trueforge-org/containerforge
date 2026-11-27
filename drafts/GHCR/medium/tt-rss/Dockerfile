
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

# Upstream builds on Alpine with PHP 8.5; this uses the Ubuntu php8.5 packages (same layout as apps/bookstack).
RUN echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    postgresql-client \
    rsync \
    php8.5-apcu \
    php8.5-cli \
    php8.5-curl \
    php8.5-fpm \
    php8.5-gd \
    php8.5-intl \
    php8.5-mbstring \
    php8.5-pgsql \
    php8.5-sodium \
    php8.5-xml \
    php8.5-zip && \
  rm -rf /var/lib/apt/lists/*

# VERSION is a commit SHA (upstream has no releases). UNVERIFIED: archive sha256 is not recorded; add it once the archive is fetched.
RUN echo "**** fetch tt-rss source ****" && \
  mkdir -p /app/tt-rss && \
  curl -fL -o /tmp/tt-rss.tar.gz \
    "https://github.com/tt-rss/tt-rss/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/tt-rss.tar.gz -C /app/tt-rss --strip-components=1 && \
  rm /tmp/tt-rss.tar.gz && \
  echo "**** fetch nginx_xaccel plugin ****" && \
  mkdir -p /app/tt-rss/plugins.local && \
  git clone --depth=1 https://github.com/tt-rss/tt-rss-plugin-nginx-xaccel /app/tt-rss/plugins.local/nginx_xaccel && \
  rm -rf /app/tt-rss/plugins.local/nginx_xaccel/.git && \
  echo "**** install license ****" && \
  mkdir -p /usr/share/licenses/tt-rss && \
  cp /app/tt-rss/LICENSE /usr/share/licenses/tt-rss/LICENSE

# UNVERIFIED: the plugin is cloned at HEAD as upstream does. Pin a commit before merge.

COPY --chmod=0644 defaults/www.conf /etc/php/8.5/fpm/pool.d/www.conf

RUN chown -R apps:apps /app && \
  chmod -R 755 /app

ENV \
  SCRIPT_ROOT=/app/tt-rss/.docker/app \
  TTRSS_PHP_EXECUTABLE=/usr/bin/php8.5 \
  TTRSS_PLUGINS="auth_internal, note, nginx_xaccel" \
  TTRSS_DB_HOST=postgresql \
  TTRSS_DB_PORT=5432 \
  HOME=/config \
  TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 9000

VOLUME /config
