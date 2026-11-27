# UI build stage (thrown away). The digest is the one upstream pins because a floating
# node:22-alpine tag failed under QEMU arm64.
FROM docker.io/library/node:22-alpine@sha256:c610fcdfb1d5b4740dd70c284ed3cb16bb857e0f7166196e36a5501df7a3aa32 AS ui

ARG VERSION

RUN \
  echo "**** fetch source code ****" && \
  apk add --no-cache curl && \
  mkdir -p /src && \
  curl -fL -o /tmp/metube-src.tar.gz \
    "https://github.com/alexta69/metube/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/metube-src.tar.gz -C /src --strip-components=1 && \
  rm -f /tmp/metube-src.tar.gz

WORKDIR /src/ui

# UNVERIFIED: the build output path below (ui/dist/metube) must match upstream's build output; confirm in the build.
RUN \
  echo "**** build ui ****" && \
  corepack enable && \
  corepack prepare pnpm --activate && \
  CI=true pnpm install && \
  pnpm run build

############## runtime stage ##############
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
ARG FFMPEG_BRANCH=8.1
USER root

ENV PORT=8081 \
    DOWNLOAD_DIR=/config/downloads \
    AUDIO_DOWNLOAD_DIR=/config/downloads \
    TEMP_DIR=/tmp/metube \
    STATE_DIR=/config/state \
    XDG_CACHE_HOME=/tmp/cache \
    HOME=/config

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    aria2 \
    ca-certificates \
    curl \
    unzip \
    xz-utils && \
  rm -rf /var/lib/apt/lists/*

# ffmpeg and bgutil-pot, arch mapped like upstream
# UNVERIFIED: both use the floating "latest" release (upstream behaviour). Pin dated tags in the PR.
RUN \
  echo "**** install ffmpeg and bgutil-pot ****" && \
  case "${TARGETARCH}" in \
    amd64) FFARCH=linux64; BGARCH=x86_64 ;; \
    arm64) FFARCH=linuxarm64; BGARCH=aarch64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  mkdir -p /tmp/ffmpeg-extract && \
  curl -fL "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n${FFMPEG_BRANCH}-latest-${FFARCH}-gpl-${FFMPEG_BRANCH}.tar.xz" | \
    tar -xJ -C /tmp/ffmpeg-extract --wildcards '*/bin/ffmpeg' '*/bin/ffprobe' && \
  install -m 0755 /tmp/ffmpeg-extract/*/bin/ffmpeg /tmp/ffmpeg-extract/*/bin/ffprobe /usr/local/bin/ && \
  curl -fL -o /usr/local/bin/bgutil-pot \
    "https://github.com/jim60105/bgutil-ytdlp-pot-provider-rs/releases/latest/download/bgutil-pot-linux-${BGARCH}" && \
  chmod 0755 /usr/local/bin/bgutil-pot && \
  rm -rf /tmp/ffmpeg-extract

# app source and lock file from the upstream tag (not from this folder)
COPY --from=ui /src/pyproject.toml /src/uv.lock /app/
COPY --from=ui /src/app /app/app
COPY --from=ui /src/ui/dist/metube /app/ui/dist/metube
COPY --from=ui /src/LICENSE /usr/share/licenses/metube/LICENSE

RUN \
  echo "**** install python deps into /app/venv (read-only at runtime) ****" && \
  python3 -m pip install --no-cache-dir uv && \
  cd /app && \
  UV_CACHE_DIR=/tmp/uv-cache UV_PROJECT_ENVIRONMENT=/app/venv \
    uv sync --frozen --no-dev --no-install-project --compile-bytecode && \
  python3 -m pip uninstall -y uv && \
  SITE_PACKAGES="$(/app/venv/bin/python -c 'import site; print(site.getsitepackages()[0])')" && \
  # UNVERIFIED: the plugin zip is assumed to unpack straight into site-packages (upstream behaviour).
  curl -fL -o /tmp/bgutil-plugin.zip \
    "https://github.com/jim60105/bgutil-ytdlp-pot-provider-rs/releases/latest/download/bgutil-ytdlp-pot-provider-rs.zip" && \
  unzip -o /tmp/bgutil-plugin.zip -d "${SITE_PACKAGES}" && \
  rm -rf /tmp/bgutil-plugin.zip /tmp/uv-cache && \
  apt-get purge -y --auto-remove unzip && \
  mkdir -p /config && \
  chown -R apps:apps /config

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8081

VOLUME /config
WORKDIR /app
ENTRYPOINT ["/start.sh"]
