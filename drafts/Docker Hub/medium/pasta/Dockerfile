
# Build stage: build the frontend and install dependencies from the upstream tag.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

# upstream release tag (3.0.0, GPL-3.0)
ARG VERSION

USER root

ENV NPM_CONFIG_CACHE=/tmp/npm-cache

RUN mkdir -p /tmp/src \
 && curl -fsSL -o /tmp/src.tgz "https://github.com/cglatot/pasta/archive/refs/tags/${VERSION}.tar.gz" \
 && tar -xzf /tmp/src.tgz -C /tmp/src --strip-components=1 \
 && rm -f /tmp/src.tgz

WORKDIR /tmp/src

# UNVERIFIED: the Node major in this base (plan wants Node 22.18+ or 24 for native TypeScript)
RUN npm ci \
 && npm run build \
 && npm prune --omit=dev

# Runtime stage
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

USER root

RUN mkdir -p /app /config /usr/share/licenses/pasta

COPY --from=build /tmp/src/dist /app/dist
COPY --from=build /tmp/src/src/shared /app/src/shared
COPY --from=build /tmp/src/server/src /app/server/src
COPY --from=build /tmp/src/package.json /app/package.json
# UNVERIFIED: runtime node_modules are needed by the server; drop this line if the image runs without them
COPY --from=build /tmp/src/node_modules /app/node_modules
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/pasta/LICENSE

RUN chown -R root:root /app \
 && chmod -R 755 /app

ENV NODE_ENV=production \
    PORT=3000 \
    PASTA_MODE=server \
    PASTA_CONFIG_DIR=/config \
    PASTA_DIST_DIR=/app/dist

# run as 568
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME ["/config"]
WORKDIR /app
