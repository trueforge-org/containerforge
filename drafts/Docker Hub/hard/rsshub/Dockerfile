# Stage 1: build RSSHub from the tagged source. Upstream publishes no release assets or checksums (UNVERIFIED for this tag).
# UNVERIFIED: no digest for node:26-trixie is in the repo yet; pin it from the upstream Dockerfile at implementation.
FROM docker.io/library/node:26-trixie@sha256:f8e5d4bb28fa55c74f1345166a082a10b7c68f22304350c1ce0d18358ae94996 AS build

ARG VERSION

ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=true

# Simplified: upstream prunes node_modules with minify-docker.js; the initial draft ships the full production tree instead.
RUN \
  echo "**** build rsshub ${VERSION} ****" && \
  mkdir -p /build && \
  curl -fsSL "https://github.com/DIYgod/RSSHub/archive/refs/tags/${VERSION}.tar.gz" \
    | tar xz -C /build --strip-components=1 && \
  cd /build && \
  corepack enable && \
  pnpm install --frozen-lockfile && \
  pnpm rb && \
  pnpm build && \
  pnpm install --prod --frozen-lockfile && \
  mv /build /app

# Stage 2: runtime
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

USER root

# UNVERIFIED: the Node major in python-node must satisfy RSSHub's engines field (upstream builds on Node 26).
COPY --from=build /app /app

RUN \
  mkdir -p /usr/share/licenses/rsshub && \
  cp /app/LICENSE /usr/share/licenses/rsshub/ && \
  chmod -R a+rX /app

# No browser is bundled. Browser routes use a remote browser through PLAYWRIGHT_WS_ENDPOINT.
ENV NODE_ENV=production \
  TZ=Etc/UTC \
  HOME=/config \
  npm_config_cache=/tmp/.npm \
  XDG_CACHE_HOME=/tmp \
  PLAYWRIGHT_BROWSERS_PATH=/tmp/ms-playwright

USER apps
COPY --chmod=0755 . /

EXPOSE 1200

VOLUME /config

WORKDIR /app
