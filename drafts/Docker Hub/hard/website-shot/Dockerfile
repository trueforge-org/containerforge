# Initial draft. Upstream Flowko/website-shot is archived (2024-03-10), so no security fixes are expected.
# UNVERIFIED: Playwright Chromium working with the puppeteer 14 used upstream, and the Node version in the base.

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# Upstream website-shot release tag (VERSION in docker-bake.hcl)
ARG VERSION

ENV HOME=/tmp \
    NODE_OPTIONS=--openssl-legacy-provider \
    NUXT_HOST=0.0.0.0 \
    NUXT_PORT=3000 \
    PASSWORD_PROTECT=0 \
    RUNNING_DOCKER=1 \
    BLOCK_ADS=1 \
    PUPPETEER_SKIP_DOWNLOAD=1 \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 \
    PLAYWRIGHT_BROWSERS_PATH=/usr/local/share/playwright \
    YARN_CACHE_FOLDER=/tmp/yarn-cache \
    npm_config_cache=/tmp/npm-cache

USER root

# Chromium and a CJK font. Ubuntu's chromium-browser is a snap shim and cannot run in a container,
# so Chromium comes from Playwright and is linked where upstream expects it.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        fonts-wqy-zenhei; \
    rm -rf /var/lib/apt/lists/*; \
    command -v yarn >/dev/null 2>&1 || npm install -g yarn@1.22.22; \
    npm install -g playwright@1.65.1; \
    playwright install --with-deps chromium; \
    chrome="$(find /usr/local/share/playwright -path '*chrome-linux*' -type f -name chrome | head -n 1)"; \
    test -n "$chrome"; \
    ln -sf "$chrome" /usr/bin/chromium-browser; \
    rm -rf /tmp/*

WORKDIR /app/website-shot

# Source from the pinned release tag. Integrity is pinned by yarn.lock with --frozen-lockfile (no upstream checksum).
RUN set -eux; \
    curl -fsSL "https://github.com/Flowko/website-shot/archive/refs/tags/v${VERSION}.tar.gz" \
        | tar xz -C /app/website-shot --strip-components=1; \
    yarn install --frozen-lockfile; \
    yarn generate; \
    yarn build; \
    rm -rf /app/website-shot/screenshots; \
    ln -s /config/screenshots /app/website-shot/screenshots; \
    mkdir -p /usr/share/licenses/website-shot; \
    cp /app/website-shot/LICENSE /usr/share/licenses/website-shot/LICENSE; \
    chown -R root:root /app && chmod -R a+rX /app; \
    rm -rf /tmp/*

EXPOSE 3000

USER apps
COPY --chmod=0755 . /

VOLUME ["/config"]

CMD ["/start.sh"]
