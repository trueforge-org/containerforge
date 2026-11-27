FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
USER root

# Build stage: fetch the tagged source and build the web GUI.
# UNVERIFIED: the tag archive has no published checksum; pinned by tag v${VERSION}
# (tag resolves to commit 082abee9ea59cdc653fe107b086358e957670575 per GitHub API).
# Upstream's "remove frontend packages" size hack is replaced by npm prune --omit=dev.
ENV npm_config_cache=/tmp/npm

RUN set -eux; \
    mkdir -p /tmp/src /app/tasmocompiler; \
    curl -fsSL -o /tmp/tasmocompiler.tar.gz \
        "https://github.com/benzino77/tasmocompiler/archive/refs/tags/v${VERSION}.tar.gz"; \
    tar xzf /tmp/tasmocompiler.tar.gz -C /tmp/src --strip-components=1; \
    rm -f /tmp/tasmocompiler.tar.gz; \
    cd /tmp/src; \
    npm ci; \
    npm run build; \
    npm prune --omit=dev; \
    cp -a /tmp/src/. /app/tasmocompiler/; \
    rm -rf /tmp/src /tmp/npm

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

# PlatformIO runs at request time (firmware builds). Its venv sits outside /app and /config,
# and all PlatformIO state and HOME go to /tmp, so the rootfs can stay read-only.
ENV HOME=/tmp/home \
    PLATFORMIO_CORE_DIR=/tmp/platformio \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    PATH=/usr/local/lib/platformio-venv/bin:$PATH

# UNVERIFIED: pioarduino==6.2.0 is the pin in upstream's Dockerfile at the draft commit;
# not re-checked at the v14.0.3 tag. uv is unpinned, as upstream.
# UNVERIFIED: git is kept from upstream; check whether python-node already ships it.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git; \
    python3 -m venv /usr/local/lib/platformio-venv; \
    /usr/local/lib/platformio-venv/bin/pip install --no-cache-dir "pioarduino==6.2.0" uv; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY --from=build /app/tasmocompiler /app/tasmocompiler
RUN set -eux; \
    chmod -R a+rX /app/tasmocompiler; \
    install -D -m 0644 /app/tasmocompiler/LICENSE /usr/share/licenses/tasmocompiler/LICENSE

USER apps
COPY --chmod=0755 . /

EXPOSE 3000/tcp

WORKDIR /app/tasmocompiler
