# UNVERIFIED: the Node major in python-node:3.15.2 must be 24 or newer (upstream uses node:24-alpine)
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION

ENV YARN_CACHE_FOLDER=/tmp/yarn \
    NPM_CONFIG_CACHE=/tmp/npm \
    DO_NOT_TRACK=1

USER root

# Fetch the release tarball and verify it against the published checksum
# UNVERIFIED: the .sha256 file format (it must name the tarball as sha256sum expects)
RUN set -eux; \
    mkdir -p /tmp/src; \
    curl -fsSL -o /tmp/dashy.tar.gz "https://github.com/Lissy93/dashy/releases/download/${VERSION}/dashy-${VERSION}.tar.gz"; \
    curl -fsSL -o /tmp/dashy.tar.gz.sha256 "https://github.com/Lissy93/dashy/releases/download/${VERSION}/dashy-${VERSION}.tar.gz.sha256"; \
    (cd /tmp && sha256sum -c dashy.tar.gz.sha256); \
    tar -xzf /tmp/dashy.tar.gz -C /tmp/src --strip-components=1; \
    rm -f /tmp/dashy.tar.gz /tmp/dashy.tar.gz.sha256

# UNVERIFIED: the tarball holds source (not a prebuilt dist/), and yarn is present in the base
# (if not, corepack enable is the fallback)
RUN set -eux; \
    cd /tmp/src; \
    corepack enable; \
    yarn install --frozen-lockfile --network-timeout 600000; \
    yarn build

# Production dependencies only (as upstream's deps stage)
FROM build AS deps
RUN set -eux; \
    cd /tmp/src; \
    rm -rf node_modules; \
    yarn install --production --frozen-lockfile --network-timeout 600000; \
    yarn cache clean

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

ENV NODE_ENV=production \
    IS_DOCKER=true \
    PORT=8080

USER root

COPY --from=deps /tmp/src/node_modules /app/dashy/node_modules
COPY --from=build /tmp/src/dist /app/dashy/dist
COPY --from=build /tmp/src/public /app/dashy/public
COPY --from=build /tmp/src/services /app/dashy/services
COPY --from=build /tmp/src/server.js /app/dashy/server.js
COPY --from=build /tmp/src/package.json /app/dashy/package.json
COPY --from=build /tmp/src/src/utils/config/ConfigSchema.json /app/dashy/src/utils/config/ConfigSchema.json
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/dashy/LICENSE

# Default config, seeded into /config by start.sh only when missing
COPY --from=build /tmp/src/user-data/conf.yml /defaults/conf.yml

# Config and icons are written to /config (app root is read-only at runtime)
RUN set -eux; \
    ln -s /config/user-data /app/dashy/user-data; \
    ln -s /config/item-icons /app/dashy/public/item-icons; \
    chown -R root:root /app/dashy /defaults; \
    chmod -R 0755 /app/dashy /defaults

# run as 568
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME ["/config"]
WORKDIR /app/dashy
CMD ["/start.sh"]
