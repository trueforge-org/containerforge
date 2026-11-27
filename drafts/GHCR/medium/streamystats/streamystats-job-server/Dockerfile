# UNVERIFIED: ubuntu base digest is taken from the plan (sibling apps pin f01a4295...)
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

# build variables
ARG VERSION
USER root

# UNVERIFIED: oven/bun:1.4.2 digest not pinned yet; binary path assumed /usr/local/bin/bun
COPY --from=oven/bun:1.4.2 /usr/local/bin/bun /usr/local/bin/bun

ENV BUN_INSTALL_CACHE_DIR=/tmp/bun-cache

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src && \
  curl -fL \
    "https://github.com/fredrikburmester/streamystats/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C \
    /tmp/src --strip-components=1 && \
  echo "**** compile job server ****" && \
  cd /tmp/src && \
  bun install --frozen-lockfile && \
  cd packages/database && \
  bun run build && \
  bun build ./src/migrate-entrypoint.ts --compile --minify --outfile migrate-bin && \
  cd /tmp/src/apps/job-server && \
  bun add geoip-lite@2.0.3 && \
  bun build ./src/index.ts --compile --minify --outfile server && \
  echo "**** stage runtime files ****" && \
  mkdir -p \
    /out/node_modules/.bun/geoip-lite@2.0.3/node_modules/geoip-lite && \
  cp /tmp/src/packages/database/migrate-bin /out/ && \
  # UNVERIFIED: drizzle/ location (packages/database assumed)
  cp -r /tmp/src/packages/database/drizzle /out/ && \
  cp /tmp/src/apps/job-server/server /out/ && \
  cp -r \
    /tmp/src/node_modules/.bun/geoip-lite@2.0.3/node_modules/geoip-lite/data \
    /out/node_modules/.bun/geoip-lite@2.0.3/node_modules/geoip-lite/ && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/bun-cache \
    /tmp/src \
    /var/lib/apt/lists/*

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
USER root

COPY --from=build --chmod=0755 /out/ /app/streamystats-job-server/

ENV NODE_ENV=production \
    PORT=3005 \
    HOST=0.0.0.0 \
    HOME=/config

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3005
VOLUME ["/config"]

WORKDIR /app/streamystats-job-server
