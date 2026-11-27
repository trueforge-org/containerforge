FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION=1.13.0

# Caches go to /tmp. NODE_ENV stays unset here so devDependencies install for the builds.
ENV npm_config_cache=/tmp/npm

USER root

# Fetch the source tree of the release tag. It includes reverse-proxy/ (Caddyfiles) and LICENSE.
RUN mkdir -p /tmp/src \
 && curl -fsSL "https://github.com/stonith404/pingvin-share/archive/refs/tags/v${VERSION}.tar.gz" \
      | tar xz -C /tmp/src --strip-components=1

# Same steps as the upstream builder stages.
# UNVERIFIED: the Node major in python-node (upstream uses node:22). Confirm with `node --version` on the first build.
RUN cd /tmp/src/frontend \
 && npm ci \
 && npm run build \
 && cp -r public .next/standalone/public \
 && cp -r .next/static .next/standalone/.next/static \
 && mkdir -p /tmp/img-defaults \
 # UNVERIFIED: the default images path in the source tree. Upstream copies them to /tmp/img.
 && if [ -d public/img ]; then cp -r public/img/. /tmp/img-defaults/; fi \
 && cd /tmp/src/backend \
 && npm ci \
 && npx prisma generate \
 && npm run build \
 && npm prune --omit=dev \
 && rm -rf /tmp/npm


FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION=1.13.0

ENV NODE_ENV=docker \
    HOME=/config \
    XDG_DATA_HOME=/tmp/caddy-data \
    XDG_CONFIG_HOME=/tmp/caddy-config

USER root

# UNVERIFIED: caddy package availability on this base. If it is missing, the routing decision in the PR is open (plan section 10).
RUN apt-get update \
 && apt-get install -y --no-install-recommends caddy \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/frontend /app/backend /app/reverse-proxy /usr/share/pingvin-share /usr/share/licenses/pingvin-share

COPY --from=build /tmp/src/frontend/.next/standalone /app/frontend
COPY --from=build /tmp/src/backend /app/backend
COPY --from=build /tmp/src/reverse-proxy /app/reverse-proxy
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/pingvin-share/LICENSE
COPY --from=build /tmp/img-defaults /usr/share/pingvin-share/img-defaults

# Writable paths point at /config. The targets are created by start.sh, so the links may dangle at build time.
RUN rm -rf /app/backend/data /app/frontend/public/img \
 && mkdir -p /app/frontend/public \
 && ln -s /config/data /app/backend/data \
 && ln -s /config/img /app/frontend/public/img \
 && chmod -R 755 /app /usr/share/pingvin-share /usr/share/licenses/pingvin-share

WORKDIR /config
VOLUME ["/config"]
EXPOSE 3000

COPY --chmod=0755 . /

USER apps
