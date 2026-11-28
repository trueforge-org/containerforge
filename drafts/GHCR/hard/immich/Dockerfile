
# Draft from plan.md section 4 (route: build from source). UNVERIFIED items are marked inline.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  COREPACK_HOME=/tmp/corepack \
  PNPM_HOME=/tmp/pnpm-store \
  SHARP_FORCE_GLOBAL_LIBVIPS=true

# UNVERIFIED: Node major version must match v3.4.2 `engines` / `.nvmrc`; pin it once read from the source.
RUN echo "*** Installing build dependencies ***" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libvips-dev \
    nodejs \
    npm && \
  rm -rf /var/lib/apt/lists/*

# No checksum file is published upstream; the source is pinned by tag.
RUN echo "*** Downloading Immich source ***" && \
  curl -fL -o /tmp/immich.tar.gz \
    "https://github.com/immich-app/immich/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /tmp/immich && \
  tar xzf /tmp/immich.tar.gz -C /tmp/immich --strip-components=1 && \
  rm /tmp/immich.tar.gz

WORKDIR /tmp/immich

# UNVERIFIED: sdk and plugin-sdk filter names, the web build output path and the cli layout must be confirmed
# against the v3.4.2 workspace. Build order follows upstream: sdk, server, web, cli.
RUN echo "*** Building Immich ***" && \
  corepack enable pnpm && \
  pnpm install --frozen-lockfile && \
  pnpm --filter @immich/sdk build && \
  pnpm --filter immich build && \
  pnpm --filter immich --prod deploy /output/app/immich/server && \
  pnpm --filter immich-web build && \
  cp -a /tmp/immich/web/build /output/app/immich/web && \
  pnpm --filter @immich/cli build && \
  pnpm --filter @immich/cli --prod deploy /output/app/immich/cli && \
  install -D -m 0644 /tmp/immich/LICENSE /output/usr/share/licenses/immich/LICENSE

# UNVERIFIED: upstream symlinks the cli as server/bin/immich, and PATH below expects it there.
# UNVERIFIED: restic and restic-proxy (upstream copies them into the server image) are not added here until the server is confirmed to need them.

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  NODE_ENV=production \
  HOME=/config \
  PATH=/app/immich/server/bin:${PATH}
# UNVERIFIED: a media-root variable (for example IMMICH_MEDIA_LOCATION=/data) must be read from the v3.4.2 source before it is set.

# UNVERIFIED: the Node runtime version must match the build stage.
RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libvips42 \
    nodejs \
    tini && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /output/ /

RUN echo "*** Setting up paths ***" && \
  ln -s /config/data /data && \
  chown -R apps:apps /app/immich && chmod -R 755 /app/immich

USER apps
COPY --chmod=0755 . /

EXPOSE 2283

VOLUME /config
WORKDIR /app/immich/server
