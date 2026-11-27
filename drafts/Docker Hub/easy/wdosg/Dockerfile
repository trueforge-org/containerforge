FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

ENV HOME=/config \
    NODE_ENV=production \
    NPM_CONFIG_CACHE=/tmp/npm-cache \
    NPM_CONFIG_UPDATE_NOTIFIER=false

USER root

# build-essential is only needed if sqlite3 has no prebuilt binary for this arch. Purged after npm ci.
# UNVERIFIED: the Node major in the base works with sqlite3@5 (upstream uses Node 23).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends build-essential; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p /app/wdosg /usr/share/licenses/wdosg; \
    curl -fsSL "https://github.com/SoulRaven80/wdosg/archive/refs/tags/v${VERSION#v}.tar.gz" \
        -o /tmp/wdosg.tar.gz; \
    tar xzf /tmp/wdosg.tar.gz -C /app/wdosg --strip-components=1; \
    rm -f /tmp/wdosg.tar.gz; \
    cd /app/wdosg; \
    npm ci --omit=dev --no-audit --no-fund; \
    cp LICENSE /usr/share/licenses/wdosg/LICENSE; \
    chown -R root:root /app; \
    chmod -R u=rwX,go=rX /app; \
    npm cache clean --force; \
    apt-get purge -y --auto-remove build-essential; \
    apt-get clean; \
    rm -rf /tmp/* /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 3001
VOLUME /config
