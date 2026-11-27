
# UNVERIFIED: Node >=24 is required by upstream package.json engines; confirm the node version in this base before the first build.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: apt package list and the Chromium runtime libraries needed by the bundled browser.
# Check against the base first; an alternative is `npx playwright install-deps chromium`.
RUN \
  echo "**** install browser runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    fonts-liberation \
    fonts-noto-color-emoji \
    libnss3 \
    libgbm1 \
    libasound2t64 \
    libatk-bridge2.0-0t64 \
    libgtk-3-0t64 \
    libxss1 \
    xvfb && \
  echo "**** fetch browserless ****" && \
  mkdir -p /app && \
  curl -fsSL -o \
    /tmp/browserless.tar.gz \
    "https://github.com/browserless/browserless/archive/refs/tags/v${VERSION}.tar.gz" && \
  # UNVERIFIED: no checksum is published upstream for the source tarball.
  tar xzf \
    /tmp/browserless.tar.gz -C \
    /app --strip-components=1 && \
  echo "**** build and install bundled browsers ****" && \
  cd /app && \
  # UNVERIFIED: script names (build, install:browsers) per upstream package.json; confirm on first build.
  npm_config_cache=/tmp/npm npm ci && \
  npm run build && \
  PLAYWRIGHT_BROWSERS_PATH=/app/browsers npm run install:browsers && \
  npm_config_cache=/tmp/npm npm prune --omit=dev && \
  echo "**** license ****" && \
  mkdir -p /usr/share/licenses/browserless-chrome && \
  cp /app/LICENSE /usr/share/licenses/browserless-chrome/LICENSE && \
  chown -R apps:apps /app && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /root/.npm \
    /var/lib/apt/lists/*

ENV \
  HOME=/config \
  HOST=0.0.0.0 \
  PORT=3000 \
  PLAYWRIGHT_BROWSERS_PATH=/app/browsers \
  XDG_CACHE_HOME=/tmp/.cache

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /config
