# Outline 1.13.0 (BUSL-1.1, not an OSI open-source license), built from the upstream source tag on the ContainerForge ubuntu base.
# Upstream: https://github.com/outline/outline (Dockerfile + Dockerfile.base at v1.13.0, reviewed; no tarball checksum published, integrity comes from yarn.lock).
# UNVERIFIED: build memory need; upstream sets a 24 GB heap, this draft uses 8 GB.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION

ENV HOME=/tmp \
    NODE_OPTIONS=--max-old-space-size=8192 \
    YARN_CACHE_FOLDER=/tmp/yarn-cache \
    npm_config_cache=/tmp/npm \
    COREPACK_HOME=/tmp/corepack

USER root
WORKDIR /tmp/outline

RUN apt-get update && \
    apt-get install -y --no-install-recommends cmake build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/outline.tar.gz "https://github.com/outline/outline/archive/refs/tags/v${VERSION}.tar.gz" && \
    tar xzf /tmp/outline.tar.gz -C /tmp/outline --strip-components=1 && \
    rm /tmp/outline.tar.gz

# UNVERIFIED: yarn 4 from the packageManager field; --network-timeout raised as upstream does.
RUN npm install -g corepack && \
    corepack enable && \
    yarn install --immutable --network-timeout 1000000 && \
    yarn build && \
    yarn workspaces focus --production && \
    yarn cache clean

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ENV NODE_ENV=production \
    MALLOC_ARENA_MAX=2 \
    PORT=3000 \
    HOME=/tmp \
    FILE_STORAGE_LOCAL_ROOT_DIR=/config/data

USER root

RUN mkdir -p /app/outline /usr/share/licenses/outline

COPY --from=builder --chown=568:568 /tmp/outline/build /app/outline/build
COPY --from=builder --chown=568:568 /tmp/outline/server /app/outline/server
COPY --from=builder --chown=568:568 /tmp/outline/public /app/outline/public
COPY --from=builder --chown=568:568 /tmp/outline/node_modules /app/outline/node_modules
COPY --from=builder --chown=568:568 /tmp/outline/.sequelizerc /tmp/outline/package.json /app/outline/

COPY --from=builder /tmp/outline/LICENSE /usr/share/licenses/outline/LICENSE

USER apps
COPY --chmod=0755 . /

WORKDIR /app/outline

EXPOSE 3000

VOLUME /config

USER apps
