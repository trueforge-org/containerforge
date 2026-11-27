# hadolint ignore=DL3007
# UNVERIFIED: base digest. Plan says 19cb2ceef...; the digest used by every other app in apps/ is f01a4295f...
# This draft uses the repo-wide digest. Confirm which one is the 26.04 image before merge.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS source

ARG VERSION

USER root
WORKDIR /src

# Upstream publishes no release assets and no checksum. Pinned by git tag only.
RUN curl -fsSL "https://github.com/andrii-kryvoviaz/slink/archive/refs/tags/v${VERSION}.tar.gz" -o /tmp/slink.tar.gz && \
    tar xzf /tmp/slink.tar.gz --strip-components=1 -C /src && \
    rm -f /tmp/slink.tar.gz

# ---------------------------------------------------------------------------
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS client

ENV HOME=/tmp

USER root
WORKDIR /src/services/client

COPY --from=source /src /src

# Mirrors upstream build-client and deps-client-prod (docker/Dockerfile.prod).
RUN corepack enable && \
    pnpm install --frozen-lockfile && \
    NODE_OPTIONS="--max-old-space-size=2048 --expose-gc" pnpm build && \
    mkdir -p /out/client && \
    cp -a build /out/client/build && \
    cp package.json /out/client/package.json && \
    cp server.js /out/client/server.js && \
    pnpm install --prod --frozen-lockfile --ignore-scripts && \
    cp -a node_modules /out/client/node_modules && \
    rm -rf /tmp/* /var/tmp/*

# ---------------------------------------------------------------------------
# UNVERIFIED: PHP 8.5 package names and the vips extension on ubuntu 26.04.
# If there is no php8.5-vips package, build ext-vips with pecl in this stage and copy the .so.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS vendor

ENV HOME=/tmp

USER root
WORKDIR /src/services/api

COPY --from=source /src /src

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        composer \
        php8.5-cli \
        php8.5-curl \
        php8.5-gd \
        php8.5-intl \
        php8.5-mbstring \
        php8.5-sqlite3 \
        php8.5-xml \
        php8.5-zip \
        libvips-dev && \
    composer install --ignore-platform-reqs --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ---------------------------------------------------------------------------
# Caddy with xcaddy, same pattern as apps/caddy.
# UNVERIFIED: the mercure module is included because the upstream image runs a Mercure hub on 8080.
# Confirm against upstream docker/config/caddy before merge.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS caddy

ARG TARGETARCH
ARG CADDY_VERSION
ARG XCADDY_VERSION

USER root
WORKDIR /app

RUN wget -O - "https://github.com/caddyserver/xcaddy/releases/download/v${XCADDY_VERSION}/xcaddy_${XCADDY_VERSION}_linux_${TARGETARCH}.tar.gz" | tar xzf - -C "/bin" && \
    xcaddy build v${CADDY_VERSION} --output /caddy-bin \
        --with github.com/dunglas/mercure/caddy && \
    chmod 755 "/caddy-bin"

# ---------------------------------------------------------------------------
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VALKEY_PACKAGE_VERSION

# UNVERIFIED: valkey package version copied from apps/valkey. Resolve on ubuntu 26.04 before merge.
# UNVERIFIED: php8.5-fpm needs ffi enabled (see defaults/php-fpm.conf). ext-ffi package name not checked.
USER root

# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php8.5-cli \
        php8.5-curl \
        php8.5-fpm \
        php8.5-gd \
        php8.5-intl \
        php8.5-mbstring \
        php8.5-sqlite3 \
        php8.5-xml \
        php8.5-zip \
        libvips42 \
        "valkey-server=${VALKEY_PACKAGE_VERSION}" && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=source /src/services/api /app/api
COPY --from=source /src/services/api/.env.example /app/api/.env
COPY --from=vendor /src/services/api/vendor /app/api/vendor
COPY --from=client /out/client /app/client
COPY --from=caddy /caddy-bin /app/caddy
COPY --from=source /src/LICENSE /usr/share/licenses/slink/LICENSE

# Symfony cache is warmed at build time so /app/api/var/cache is read-only at runtime.
# Runtime cache and logs go to /tmp via APP_CACHE_DIR and APP_LOG_DIR.
# UNVERIFIED: the upstream image runs `slink cache:warm`, here the Symfony console is called directly.
RUN cd /app/api && \
    APP_ENV=prod php bin/console cache:warm --env=prod --no-optional-warmers && \
    mkdir -p /app/var /app/slink && \
    ln -s /config/data /app/var/data && \
    ln -s /config/images /app/slink/images && \
    rm -rf /tmp/* /var/tmp/*

ENV APP_ENV=prod \
    NODE_ENV=production \
    BODY_SIZE_LIMIT=Infinity \
    MERCURE_HUB_URL=http://127.0.0.1:8080/.well-known/mercure \
    MERCURE_PUBLIC_URL=/sse \
    APP_CACHE_DIR=/tmp/slink/cache \
    APP_LOG_DIR=/tmp/slink/log \
    XDG_DATA_HOME=/config/caddy \
    HOME=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config
WORKDIR /config

CMD ["/start.sh"]
