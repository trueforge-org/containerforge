
# Build stage: pnpm and turbo build from the tagged source.
# Upstream builds on node:26-alpine. Here the python-node base is used (Node 26 match UNVERIFIED: check node -v before finishing).
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

# set version label
ARG VERSION
# renovate: datasource=npm depName=pnpm
ARG PNPM_VERSION=12.23.0
USER root

RUN \
  echo "**** install pnpm ****" && \
  npm install -g pnpm@${PNPM_VERSION} && \
  echo "**** fetch source ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/tracearr.tar.gz \
    "https://github.com/connorgallopo/Tracearr/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/tracearr.tar.gz -C /tmp/src --strip-components=1 && \
  rm -f /tmp/tracearr.tar.gz && \
  echo "**** build ****" && \
  cd /tmp/src && \
  pnpm install --frozen-lockfile && \
  pnpm turbo run build --filter=@tracearr/shared --filter=@tracearr/server --filter=@tracearr/web

RUN \
  echo "**** stage runtime tree (paths mirror upstream runner, UNVERIFIED) ****" && \
  mkdir -p /tmp/out/apps/server/src/db /tmp/out/apps/web /tmp/out/packages/shared /tmp/out/packages/emails /tmp/out/assets && \
  cd /tmp/src && \
  cp -a package.json pnpm-lock.yaml pnpm-workspace.yaml /tmp/out/ && \
  cp -a apps/server/package.json apps/server/dist apps/server/scripts /tmp/out/apps/server/ && \
  cp -a apps/server/src/db/migrations /tmp/out/apps/server/src/db/ && \
  cp -a apps/web/package.json apps/web/dist /tmp/out/apps/web/ && \
  cp -a packages/shared/package.json packages/shared/dist /tmp/out/packages/shared/ && \
  cp -a packages/emails/package.json packages/emails/dist /tmp/out/packages/emails/ && \
  cp -a assets/logo.png /tmp/out/assets/ && \
  cd /tmp/out && \
  pnpm install --prod --frozen-lockfile --ignore-scripts --filter @tracearr/server...

# final stage
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

USER root

# postgresql-client is needed by the server (UNVERIFIED: check the base first, do not reinstall if present)
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    postgresql-client && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# runtime tree and license
# Tailscale and the GeoLite2 databases from upstream are NOT included (see PR notes).
COPY --from=build /tmp/out/ /app/tracearr/
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/tracearr/LICENSE

ENV NODE_ENV=production \
    IMAGE_CACHE_DIR=/config/tracearr/image-cache \
    HOME=/config

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /app/tracearr
