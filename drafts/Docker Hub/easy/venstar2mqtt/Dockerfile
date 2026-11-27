FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG HAJL_COMMIT

USER root

# npm caches go to /tmp, never to /config or /app.
ENV NODE_ENV=production \
  NPM_CONFIG_CACHE=/tmp/npm-cache \
  NPM_CONFIG_UPDATE_NOTIFIER=false \
  HOME=/config

# The upstream repo has no tags, so VERSION is a commit SHA. The homeautomation-js-lib
# dependency is pinned to HAJL_COMMIT.
# UNVERIFIED: that node_modules/homeautomation-js-lib ships a LICENSE file.
RUN set -eux; \
  mkdir -p /app/venstar2mqtt /usr/share/licenses/venstar2mqtt; \
  curl -fsSL -o /tmp/app.tar.gz "https://github.com/terafin/mqtt-venstar-bridge/archive/${VERSION}.tar.gz"; \
  tar xzf /tmp/app.tar.gz -C /app/venstar2mqtt --strip-components=1; \
  cd /app/venstar2mqtt; \
  npm install --omit=dev --no-audit --no-fund; \
  npm install --omit=dev --no-audit --no-fund "github:terafin/homeautomation-js-lib#${HAJL_COMMIT}"; \
  cp LICENSE /usr/share/licenses/venstar2mqtt/LICENSE; \
  cp node_modules/homeautomation-js-lib/LICENSE /usr/share/licenses/venstar2mqtt/LICENSE.homeautomation-js-lib; \
  rm -rf /app/venstar2mqtt/.git; \
  chown -R apps:apps /app; chmod -R u=rwX,go=rX /app; \
  npm cache clean --force; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /app/venstar2mqtt
VOLUME /config
