
# build stage: the server image is built from the source tarball (the release assets are desktop builds only)
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
USER root

# UNVERIFIED: the Node major version of the base. The plan requires Node 24.x, so stop the build if it differs.
RUN \
  echo "**** check runtime versions ****" && \
  node --version | grep -q '^v24\.' && \
  python3 --version

# UNVERIFIED: whether python-node already ships build-essential and python3-dev. Remove these if it does.
RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev && \
  npm install --global yarn@1.22.19 && \
  rm -rf /var/lib/apt/lists/*

# no checksum is published for the source archive (UNVERIFIED), so the download is pinned by tag only
RUN \
  echo "**** fetch source ****" && \
  mkdir -p /build && \
  curl -fsSL -o /tmp/anything-llm.tar.gz \
    "https://github.com/Mintplex-Labs/anything-llm/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/anything-llm.tar.gz -C /build --strip-components=1 && \
  rm -f /tmp/anything-llm.tar.gz

# caches go to /tmp, never into the image
ENV \
  YARN_CACHE_FOLDER=/tmp/yarn \
  npm_config_cache=/tmp/npm

RUN \
  echo "**** build frontend ****" && \
  cd /build/frontend && \
  yarn install && \
  yarn build && \
  echo "**** build server ****" && \
  cd /build/server && \
  yarn install --production && \
  ./node_modules/.bin/prisma generate --schema=./prisma/schema.prisma && \
  echo "**** build collector ****" && \
  cd /build/collector && \
  yarn install --production && \
  echo "**** place frontend and env template ****" && \
  mkdir -p /build/server/public && \
  cp -R /build/frontend/dist/. /build/server/public/ && \
  cp /build/docker/.env.example /build/server/.env && \
  echo "**** cleanup ****" && \
  rm -rf /build/frontend /tmp/yarn /tmp/npm
# UNVERIFIED: Chromium for PDF and web-scrape features. The upstream arm64 path downloads a patched build; the amd64 path is not read yet. Not included here.

# runtime stage
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# environment settings
ENV \
  NODE_ENV=production \
  ANYTHING_LLM_RUNTIME=docker \
  HOME=/config \
  STORAGE_DIR=/config/storage \
  SERVER_PORT=3001 \
  npm_config_cache=/tmp/npm \
  XDG_CACHE_HOME=/tmp

USER root

COPY --from=build /build/server /app/server
COPY --from=build /build/collector /app/collector

# /app is read-only at runtime, so the writable data is linked to /config at build time
# UNVERIFIED: these directories may ship in the source tree. The rm -rf assumes they can be replaced.
RUN \
  echo "**** link writable data to /config ****" && \
  rm -rf /app/server/storage /app/collector/hotdir /app/collector/outputs && \
  ln -s /config/storage /app/server/storage && \
  ln -s /config/hotdir /app/collector/hotdir && \
  ln -s /config/outputs /app/collector/outputs && \
  chmod -R 755 /app

USER apps
COPY --chmod=0755 . /


# UNVERIFIED: the upstream HEALTHCHECK (docker-healthcheck.sh) is not ported yet.
EXPOSE 3001

VOLUME /config

WORKDIR /config
