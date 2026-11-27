FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

ENV UPTIME_KUMA_IS_CONTAINER=1 \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1 \
    NPM_CONFIG_CACHE=/tmp/npm-cache

USER root

# UNVERIFIED: the base's Node version is enough for 2.5.12 (check node --version on the first build).
# build-essential is for native modules (sqlite); it is purged after the build.
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# No checksum is published for the tag archive; the version is pinned by tag. Record the observed sha256 in the PR.
RUN mkdir -p /app/uptime-kuma \
    && curl -fsSL -o /tmp/uptime-kuma.tar.gz "https://github.com/louislam/uptime-kuma/archive/refs/tags/${VERSION}.tar.gz" \
    && tar -xzf /tmp/uptime-kuma.tar.gz -C /app/uptime-kuma --strip-components=1 \
    && rm -f /tmp/uptime-kuma.tar.gz

# UNVERIFIED: the "build" script name in 2.5.12 package.json. Dev dependencies are needed for the frontend build, then pruned.
RUN cd /app/uptime-kuma \
    && npm ci \
    && npm run build \
    && npm prune --omit=dev

RUN apt-get purge -y --auto-remove build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# UNVERIFIED: the data directory is /app/uptime-kuma/data; point it at /config (or use a DATA_DIR env var if 2.5.12 reads one).
RUN ln -s /config /app/uptime-kuma/data \
    && mkdir -p /usr/share/licenses/uptime-kuma \
    && cp /app/uptime-kuma/LICENSE /usr/share/licenses/uptime-kuma/LICENSE \
    && chown -R root:root /app /usr/share/licenses/uptime-kuma \
    && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

WORKDIR /app/uptime-kuma
EXPOSE 3001
VOLUME /config
