FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
USER root

# UNVERIFIED: the Node version in the python-node base must satisfy the Qinglong engines field (upstream builds on Node 24.18.1 alpine).
# pnpm is pinned to the version the upstream builder uses; it is not renovate-managed.
# Built from the tag archive, since the release has no assets. UNVERIFIED: the tag archive URL until the first curl.
ENV npm_config_cache=/tmp/npm-cache

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    npm install -g pnpm@8.3.1 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/ql && \
    curl -fL "https://github.com/whyour/qinglong/archive/refs/tags/v${VERSION}.tar.gz" | \
        tar xz -C /tmp/ql --strip-components=1 && \
    cd /tmp/ql && \
    pnpm install --prod --frozen-lockfile --store-dir /tmp/pnpm-store && \
    rm -rf /tmp/pnpm-store /tmp/npm-cache

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

# Same packages as the upstream apk list. apt skips anything the base already provides.
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git curl wget jq openssh-client procps netcat-openbsd unzip && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/ql /app/qinglong
# UNVERIFIED: LICENSE is present at the repo root of the tag archive.
COPY --from=build /tmp/ql/LICENSE /usr/share/licenses/qinglong/LICENSE

# Upstream hardcodes /ql/data. /app is read-only at runtime, so the data path is linked to /config/data now.
RUN mkdir -p /config && \
    chown -R apps:apps /app /config && \
    chmod -R 755 /app && \
    rm -rf /app/qinglong/data && \
    ln -s /config/data /app/qinglong/data

ENV QL_DIR=/app/qinglong \
    QL_CONTAINER=true \
    HOME=/config \
    LANG=C.UTF-8 \
    PIP_CACHE_DIR=/tmp/pip \
    NPM_CONFIG_PREFIX=/tmp/npm-global \
    npm_config_cache=/tmp/npm-cache

WORKDIR /app/qinglong

USER apps
COPY --chmod=0755 . /

EXPOSE 5700

VOLUME /config
