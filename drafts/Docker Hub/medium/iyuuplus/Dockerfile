FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

# The upstream repository ships its Composer vendor/ directory, so no composer step is needed.
# nginx, s6-overlay and the bundled MariaDB of the upstream image are not used: webman serves
# the UI itself on 8787 and MariaDB comes from the separate mariadb app.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        php8.5-cli \
        php8.5-bcmath \
        php8.5-bz2 \
        php8.5-curl \
        php8.5-gd \
        php8.5-mbstring \
        php8.5-mysql \
        php8.5-sqlite3 \
        php8.5-xml \
        php8.5-zip; \
    printf 'upload_max_filesize=100M\npost_max_size=108M\nmemory_limit=1024M\nopcache.enable_cli=1\n' \
        > /etc/php/8.5/cli/conf.d/99-iyuu.ini; \
    mkdir -p /app/iyuuplus; \
    curl -fsSL "https://github.com/ledccn/iyuuplus-dev/archive/${VERSION}.tar.gz" \
        | tar -xz -C /app/iyuuplus --strip-components=1; \
    test -f /app/iyuuplus/start.php; \
    install -D -m 0644 /app/iyuuplus/LICENSE /usr/share/licenses/iyuuplus/LICENSE; \
    chown -R root:root /app/iyuuplus; \
    chmod -R a+rX /app/iyuuplus; \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENV HOME=/config \
    APP_ENV=prod \
    IYUU_VERSION=${VERSION}

USER apps
COPY --chmod=0755 . /

EXPOSE 8787
VOLUME /config
WORKDIR /config
