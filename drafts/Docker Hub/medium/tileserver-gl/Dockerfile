# syntax=docker/dockerfile:1

# python-node provides Node.js on glibc, which tileserver-gl needs.
# UNVERIFIED: the Node major in this base must satisfy the engines range ^20.19.0 || ^22.13.0 || 24.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

ENV NODE_ENV=production

# Runtime libraries for server-side rendering (package names UNVERIFIED on ubuntu 26.04).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        xvfb \
        libglfw3 \
        libuv1 \
        libcairo2 \
        libpango-1.0-0 \
        libjpeg-turbo8 \
        libgif7 \
        libpng16-16t64 \
        libopengl0 \
        libcurl4 \
        librsvg2-2; \
    rm -rf /var/lib/apt/lists/*

# Install the npm package into /app. npm verifies the registry integrity hash on install.
RUN set -eux; \
    mkdir -p /app/tileserver-gl; \
    cd /app/tileserver-gl; \
    npm init -y >/dev/null; \
    npm_config_cache=/tmp/npm npm install --omit=dev --no-audit --no-fund "tileserver-gl@${VERSION}"; \
    node /app/tileserver-gl/node_modules/tileserver-gl/src/main.js --help >/dev/null; \
    if [ -f /app/tileserver-gl/node_modules/tileserver-gl/LICENSE ]; then \
        mkdir -p /usr/share/licenses/tileserver-gl; \
        cp /app/tileserver-gl/node_modules/tileserver-gl/LICENSE /usr/share/licenses/tileserver-gl/LICENSE; \
    fi; \
    rm -rf /tmp/* /root/.npm; \
    chown -R root:root /app; \
    chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
