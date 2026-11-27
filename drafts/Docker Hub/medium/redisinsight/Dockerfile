# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

# Build stage: build the Node server from the source tag. The release AppImages are desktop bundles, not the server.
# python-node provides Node.js on glibc. UNVERIFIED: the Node major must be compatible with upstream node 24.x.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
USER root

ENV npm_config_cache=/tmp/npm

# Native modules are compiled during npm ci, so a compiler and python are needed here (not in the final stage).
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends build-essential python3; \
    rm -rf /var/lib/apt/lists/*

# UNVERIFIED: no upstream checksum is published for the source tarball. Pin its sha256 here after the first download and verify it.
RUN set -eux; \
    mkdir -p /tmp/src; \
    curl -fsSL -o /tmp/ri.tar.gz "https://github.com/redis/RedisInsight/archive/refs/tags/${VERSION}.tar.gz"; \
    tar xzf /tmp/ri.tar.gz -C /tmp/src --strip-components=1; \
    rm -f /tmp/ri.tar.gz

RUN set -eux; \
    cd /tmp/src; \
    npm ci --ignore-scripts; \
    npx patch-package; \
    npm ci --prefix redisinsight/api; \
    npm run build:ui; \
    npm run build:statics; \
    npm run build:api; \
    npm ci --prefix redisinsight/api --omit=dev

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
USER root

ENV NODE_ENV=production \
    RI_SERVE_STATICS=true \
    RI_BUILD_TYPE=DOCKER_ON_PREMISE \
    RI_APP_FOLDER_ABSOLUTE_PATH=/config \
    HOME=/config \
    npm_config_cache=/tmp/npm

COPY --from=build /tmp/src/redisinsight/api/dist /app/redisinsight/redisinsight/api/dist
COPY --from=build /tmp/src/redisinsight/api/node_modules /app/redisinsight/redisinsight/api/node_modules
COPY --from=build /tmp/src/redisinsight/api/package.json /app/redisinsight/redisinsight/api/package.json
COPY --from=build /tmp/src/redisinsight/ui/dist /app/redisinsight/redisinsight/ui/dist
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/redisinsight/LICENSE

RUN set -eux; \
    chown -R root:root /app; \
    chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

# RedisInsight is hard-coded to port 5540 upstream.
EXPOSE 5540
VOLUME /config
