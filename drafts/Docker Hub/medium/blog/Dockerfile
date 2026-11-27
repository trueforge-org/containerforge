FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION

USER root
WORKDIR /app

# PHP runtime and nginx from apt. Not pinned: these are runtime dependencies, not the blog release.
# UNVERIFIED: php8.5 package names (as used by apps/bookstack); confirmed by the module check below.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        php8.5-fpm \
        php8.5-cli \
        php8.5-gd \
        php8.5-curl \
        php8.5-sqlite3 \
        php8.5-pgsql \
        php8.5-mysql \
        php8.5-mbstring \
        php8.5-xml && \
    rm -rf /var/lib/apt/lists/*

# Fail the build if a module the app needs is missing
RUN for m in gd pdo_sqlite pdo_mysql pdo_pgsql exif curl; do \
        php8.5 -m | grep -qix "$m" || { echo "missing PHP module: $m" >&2; exit 1; }; \
    done

# UNVERIFIED: no checksum is published upstream for the source tarball
RUN set -eux; \
    mkdir -p /app/www; \
    curl -fsSL "https://github.com/m1k1o/blog/archive/refs/tags/v${VERSION#v}.tar.gz" | tar xz -C /app/www --strip-components=1; \
    rm -rf /app/www/data; \
    ln -s /config/data /app/www/data; \
    mkdir -p /usr/share/licenses/blog; \
    cp /app/www/LICENSE /usr/share/licenses/blog/; \
    rm -rf /tmp/*; \
    chown -R apps:apps /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
