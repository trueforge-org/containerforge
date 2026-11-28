# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS node-base

ARG VERSION
ARG APP_VERSION
ARG GITHUB_REPO=lklynet/aurral
ARG RELEASE_CHANNEL=stable

ENV HOME=/tmp \
    XDG_CACHE_HOME=/tmp \
    TMPDIR=/tmp \
    npm_config_cache=/tmp/npm \
    PNPM_HOME=/tmp/pnpm \
    COREPACK_HOME=/tmp/corepack

# Source archive. UNVERIFIED: curl must exist in the base image.
FROM node-base AS source
ARG VERSION
RUN mkdir -p /src \
    && curl -fL "https://github.com/lklynet/aurral/archive/refs/tags/v${VERSION}.tar.gz" \
        | tar xz -C /src --strip-components=1

# Frontend build. pnpm version comes from the repo packageManager field via corepack (UNVERIFIED).
FROM source AS frontend
ARG APP_VERSION
ARG GITHUB_REPO=lklynet/aurral
ARG RELEASE_CHANNEL=stable
ENV VITE_APP_VERSION=${APP_VERSION} \
    VITE_GITHUB_REPO=${GITHUB_REPO} \
    VITE_RELEASE_CHANNEL=${RELEASE_CHANNEL}
WORKDIR /src
RUN corepack enable \
    && pnpm install --frozen-lockfile --filter aurral-frontend \
    && pnpm --filter aurral-frontend run build

# Production backend dependencies. UNVERIFIED: upstream uses the vite-plus (vp) CLI; this uses pnpm.
FROM source AS backend-deps
WORKDIR /src
RUN corepack enable \
    && pnpm install --frozen-lockfile --prod --filter aurral --filter aurral-backend \
    && cd backend \
    && node -e "require('sharp')"

FROM node-base
ARG APP_VERSION
ARG GITHUB_REPO=lklynet/aurral

USER root

# python3 and ca-certificates are assumed present in the base (checked against upstream's runtime list). Check before the first build.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fontconfig \
        fonts-dejavu-core \
        fonts-noto-color-emoji \
        libjemalloc2 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Pinned by digest, as upstream v3.1.0 does.
COPY --from=mwader/static-ffmpeg:9.0.2-1@sha256:f5d100184884eb3e82b0eb14bb5ebf98da99826ac824989720297fb9ef21c822 /ffmpeg /ffprobe /usr/local/bin/
COPY --from=cloudflare/cloudflared:2026.11.2@sha256:55c7e3e8d89d5e8d20b75a82f3602cbf98e06db406e73e282073cfdc5a9a3af6 /usr/local/bin/cloudflared /usr/local/bin/cloudflared
ADD --chmod=755 --checksum=sha256:e51e69e89489f199530f13d32a4342da3ddb2cf34842f364603a066db05afbf3 https://github.com/yt-dlp/yt-dlp/releases/download/2026.10.26/yt-dlp /usr/local/bin/yt-dlp

RUN ffmpeg -version && ffprobe -version && cloudflared --version && yt-dlp --version

COPY --from=backend-deps /src/node_modules /app/aurral/node_modules
COPY --from=backend-deps /src/backend /app/aurral/backend
COPY --from=backend-deps /src/lib /app/aurral/lib
COPY --from=backend-deps /src/package.json /app/aurral/package.json
COPY --from=frontend /src/frontend/dist /app/aurral/frontend/dist
COPY --from=source /src/LICENSE /usr/share/licenses/aurral/LICENSE
# UNVERIFIED: notices for yt-dlp (Unlicense) and cloudflared (Apache-2.0) are not shipped yet. Add them if the licence check requires it.

ENV LD_PRELOAD=libjemalloc.so.2 \
    MALLOC_CONF=background_thread:true,dirty_decay_ms:1000,muzzy_decay_ms:1000 \
    APP_VERSION=${APP_VERSION} \
    GITHUB_REPO=${GITHUB_REPO}

USER apps
COPY --chmod=0755 . /

WORKDIR /app/aurral

EXPOSE 3001

VOLUME /config

CMD ["/start.sh"]
