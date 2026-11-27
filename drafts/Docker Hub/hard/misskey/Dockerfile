
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: no checksum is published. Set to the sha256 of the tag tarball before building.
# An empty value makes the sha256sum check below fail on purpose.
ARG SRC_SHA256=""
USER root

ENV \
  NODE_ENV=production \
  npm_config_cache=/tmp/.npm \
  PNPM_HOME=/tmp/pnpm \
  XDG_CACHE_HOME=/tmp/.cache

# node-gyp needs a compiler for native modules. Build dependencies stay in this stage only.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Downloading Misskey ${VERSION} ***" && \
  curl -fL -o \
    /tmp/misskey.tar.gz \
    "https://github.com/misskey-dev/misskey/archive/refs/tags/${VERSION}.tar.gz" && \
  echo "${SRC_SHA256}  /tmp/misskey.tar.gz" | sha256sum -c - && \
  mkdir -p /app/misskey && \
  tar xzf \
    /tmp/misskey.tar.gz -C \
    /app/misskey --strip-components=1 && \
  rm -f /tmp/misskey.tar.gz

WORKDIR /app/misskey

# Install the pnpm version pinned in package.json, as upstream does.
RUN npm install -g "pnpm@$(node -p "require('./package.json').packageManager.replace(/^pnpm@/, '')")" && \
  pnpm --version

# UNVERIFIED: the frontend build is RAM heavy. Plan for at least 4 GB of build memory.
RUN pnpm i --frozen-lockfile --aggregate-output && \
  pnpm build && \
  rm -rf .git

# Drop dev dependencies from the workspace. UNVERIFIED that pnpm prune works with this workspace.
RUN pnpm prune --prod

FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  NODE_ENV=production \
  LD_PRELOAD=/usr/local/lib/libjemalloc.so \
  XDG_CACHE_HOME=/tmp/.cache \
  PNPM_CONFIG_VERIFY_DEPS_BEFORE_RUN=false \
  MISSKEY_CONFIG_YML=/config/default.yml

# ffmpeg is needed for video thumbnails. tini is PID 1. jemalloc is preloaded for memory use.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    tini \
    libjemalloc2 && \
  ln -sf "/usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2" /usr/local/lib/libjemalloc.so && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build --chown=apps:apps /app/misskey /app/misskey

# Drive files go to /config (persistent). /app stays read-only at runtime.
RUN rm -rf /app/misskey/files && \
  ln -s /config/files /app/misskey/files && \
  install -D /app/misskey/LICENSE /usr/share/licenses/misskey/LICENSE

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config
