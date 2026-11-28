# UNVERIFIED: python-node is used as the Node source (plan section 3 leaves the ubuntu Node version unpinned)
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

# build variables
ARG VERSION
USER root

# UNVERIFIED: oven/bun:1.4.2 digest not pinned yet; binary path assumed /usr/local/bin/bun
COPY --from=oven/bun:1.4.5@sha256:3aa040e5445efa09d75bb428a64ba50db13e2b3ac9b6b0c7f145615f62b2ee18 /usr/local/bin/bun /usr/local/bin/bun

ENV npm_config_cache=/tmp/npm \
    BUN_INSTALL_CACHE_DIR=/tmp/bun-cache

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src && \
  curl -fL \
    "https://github.com/fredrikburmester/streamystats/archive/refs/tags/${VERSION}.tar.gz" | tar xz -C \
    /tmp/src --strip-components=1 && \
  echo "**** install and build ****" && \
  cd /tmp/src && \
  bun install --frozen-lockfile && \
  cd packages/database && \
  bun run build && \
  cd /tmp/src/apps/nextjs-app && \
  NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    NEXT_PUBLIC_VERSION="${VERSION}" \
    bun --bun next build --experimental-build-mode compile && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/bun-cache \
    /tmp/npm \
    /var/lib/apt/lists/*

############## runtime stage ##############
# UNVERIFIED: same base as the build stage, so Node is available at runtime
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
USER root

# copy the standalone Next.js output with the same layout as the upstream runner
COPY --from=build --chmod=0755 /tmp/src/apps/nextjs-app/.next/standalone/ /app/streamystats/
COPY --from=build --chmod=0755 /tmp/src/apps/nextjs-app/.next/static /app/streamystats/apps/nextjs-app/.next/static
COPY --from=build --chmod=0755 /tmp/src/apps/nextjs-app/public /app/streamystats/apps/nextjs-app/public

ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    HOSTNAME=0.0.0.0 \
    PORT=3000 \
    HOME=/config

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME ["/config"]

WORKDIR /app/streamystats/apps/nextjs-app
