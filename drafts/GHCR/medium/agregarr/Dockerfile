
# Build stage: upstream release has no binary assets, so the tag archive is built from source.
# UNVERIFIED: the Node runtime here is 24 (python-node); upstream builds on Node 20.19.5. Prove it in the build run.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build
ARG VERSION
ARG COMMIT_TAG
USER root
ENV HOME=/tmp
# UNVERIFIED: Ubuntu package names for the native module deps (upstream uses Alpine apk names).
RUN echo "*** Installing build dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    libpixman-1-dev && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Fetching Agregarr source ***" && \
  curl -fL -o /tmp/agregarr.tar.gz \
    "https://github.com/agregarr/agregarr/archive/refs/tags/v${VERSION}.tar.gz" && \
  mkdir -p /tmp/src && \
  tar xzf /tmp/agregarr.tar.gz -C /tmp/src --strip-components=1 && \
  rm /tmp/agregarr.tar.gz

WORKDIR /tmp/src
# Yarn release is taken from the repo's packageManager field via corepack (UNVERIFIED for this tag).
RUN echo "*** Building Agregarr ***" && \
  corepack enable && \
  CYPRESS_INSTALL_BINARY=0 yarn install --frozen-lockfile --network-timeout 1000000 && \
  yarn build && \
  yarn install --production --ignore-scripts --prefer-offline && \
  rm -rf src server .next/cache && \
  mkdir -p config && touch config/DOCKER && \
  printf '{"commitTag":"%s"}\n' "${COMMIT_TAG}" > committag.json && \
  rm -rf /tmp/.cache /tmp/.yarn

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

USER root

# UNVERIFIED: Chromium on Ubuntu is distributed differently (snap-based); a working browser package must be confirmed.
# UNVERIFIED: ffmpeg, tini, fontconfig, tzdata and font package names on Ubuntu 26.04.
# Base packages already present in python-node must not be re-installed (check first).
RUN echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    chromium \
    ffmpeg \
    fontconfig \
    fonts-dejavu-core \
    fonts-freefont-ttf \
    fonts-noto-color-emoji \
    libcairo2 \
    libgif7 \
    libjpeg-turbo8 \
    libpango-1.0-0 \
    libpixman-1-0 \
    tini \
    tzdata && \
  rm -rf /var/lib/apt/lists/*

# TODO (not in this draft): the upstream Dockerfile downloads about 30 Google Fonts TTFs plus FiraCode v6.2
# into /usr/share/fonts/truetype/poster-fonts. Port that block from the upstream blob at 4a101503a89ebfbb3d8ba63445f87053b11b991a
# with pinned URLs and checksums (UNVERIFIED pinning). Run `fc-cache -fv` after.

# TODO (not in this draft): Deno is required by yt-dlp (upstream installs deno@edge from Alpine). No Ubuntu
# equivalent is confirmed; choose the Ubuntu package or a pinned official release binary with checksum.

# TODO (not in this draft): yt-dlp must be pinned to a release version and checksum (upstream uses unpinned `latest`).
# Not resolved in this draft, so do not ship a `latest` download.

COPY --from=build /tmp/src /app

# Custom fonts and the DOCKER marker live under /config at runtime; /app/config is a symlink to it.
RUN mkdir -p /usr/share/licenses/agregarr && \
  cp /app/LICENSE /usr/share/licenses/agregarr/LICENSE && \
  rm -rf /app/config && \
  ln -s /config /app/config && \
  printf '<?xml version="1.0"?>\n<!DOCTYPE fontconfig SYSTEM "fonts.dtd">\n<fontconfig>\n  <dir>/config/fonts</dir>\n</fontconfig>\n' \
    > /etc/fonts/conf.d/99-agregarr-custom-fonts.conf && \
  chown -R apps:apps /app && \
  chmod -R 755 /app

ENV \
  NODE_ENV=production \
  HOME=/config \
  PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 \
  PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium

USER apps
COPY --chmod=0755 . /

EXPOSE 7171

VOLUME /config

WORKDIR /app
