# UNVERIFIED: the python-node base's Node version must satisfy the upstream engine (plan section 10)
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

# build variables
ARG VERSION
USER root

ENV YARN_ENABLE_TELEMETRY=0 \
    CI=1 \
    npm_config_cache=/tmp/npm \
    COREPACK_HOME=/tmp/corepack

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libcairo2-dev \
    libpango1.0-dev \
    libpixman-1-dev \
    pkg-config && \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src && \
  curl -fL \
    "https://github.com/Maintainerr/Maintainerr/archive/refs/tags/v${VERSION}.tar.gz" | tar xz -C \
    /tmp/src --strip-components=1 && \
  echo "**** install and build ****" && \
  cd /tmp/src && \
  corepack enable && \
  printf 'VITE_BASE_PATH=/__PATH_PREFIX__\n' > apps/ui/.env && \
  yarn install --network-timeout 99999999 && \
  yarn turbo build && \
  yarn workspaces focus --all --production && \
  mkdir -p \
    packages/contracts/node_modules \
    apps/server/node_modules && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/npm \
    /tmp/corepack \
    /tmp/yarn* \
    /var/lib/apt/lists/*

############## runtime stage ##############
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
USER root

# node-canvas runtime libraries (libpangocairo is UNVERIFIED as needed)
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpixman-1-0 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app/maintainerr

COPY --from=build --chmod=0755 /tmp/src/node_modules /app/maintainerr/node_modules
COPY --from=build --chmod=0755 /tmp/src/apps/server/dist /app/maintainerr/apps/server/dist
COPY --from=build --chmod=0755 /tmp/src/apps/server/package.json /app/maintainerr/apps/server/package.json
COPY --from=build --chmod=0755 /tmp/src/apps/server/node_modules /app/maintainerr/apps/server/node_modules
COPY --from=build --chmod=0755 /tmp/src/apps/server/assets /app/maintainerr/apps/server/assets
# bundled UI; start.sh copies it to ${DATA_DIR}/ui on each boot
COPY --from=build --chmod=0755 /tmp/src/apps/ui/dist /app/maintainerr/apps/server/dist/ui
COPY --from=build --chmod=0755 /tmp/src/packages/contracts/dist /app/maintainerr/packages/contracts/dist
COPY --from=build --chmod=0755 /tmp/src/packages/contracts/package.json /app/maintainerr/packages/contracts/package.json
COPY --from=build --chmod=0755 /tmp/src/packages/contracts/node_modules /app/maintainerr/packages/contracts/node_modules
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/maintainerr/LICENSE

ENV NODE_ENV=production \
    DEBUG=false \
    UI_PORT=6246 \
    UI_HOSTNAME=0.0.0.0 \
    DATA_DIR=/config \
    BASE_PATH="" \
    UV_USE_IO_URING=0

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 6246
VOLUME /config

WORKDIR /app/maintainerr
