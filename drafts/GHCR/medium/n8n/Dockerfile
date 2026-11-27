# NOTE: initial draft, not built. Open decisions (plan section 10): the version (2.49.6 in the
# plan, 2.49.8 seen as latest on 2026-11-27) and the Sustainable Use License for distribution.
# The base Node major must be >= 24 (n8n engines), which is UNVERIFIED for python-node.

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

# set version label
ARG VERSION
USER root

ENV npm_config_cache=/tmp/npm-cache \
    HOME=/tmp/home

# Install the published npm package into a prefix under /app. Build-time writes to /app are fine.
# Native modules (isolated-vm, sqlite3, kafka) compile here for this architecture.
RUN \
  echo "**** install n8n ****" && \
  mkdir -p /app/n8n /tmp/home && \
  npm install -g --prefix /app/n8n "n8n@${VERSION}" && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  rm -rf \
    /tmp/* \
    /root/.npm

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
USER root

COPY --from=build /app/n8n /app/n8n
# UNVERIFIED: LICENSE.md is at the root of the npm package. Confirm the path in the build.
COPY --from=build /app/n8n/lib/node_modules/n8n/LICENSE.md /usr/share/licenses/n8n/LICENSE.md

ENV NODE_ENV=production \
    SHELL=/bin/sh \
    # UNVERIFIED: upstream sets this per build (dev for snapshots). 'stable' is for release builds.
    N8N_RELEASE_TYPE=stable \
    # Chart-verified: the TrueCharts chart sets N8N_USER_FOLDER=/data, so the data folder moves to /config.
    N8N_USER_FOLDER=/config \
    XDG_CACHE_HOME=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 5678

VOLUME /config
WORKDIR /config
