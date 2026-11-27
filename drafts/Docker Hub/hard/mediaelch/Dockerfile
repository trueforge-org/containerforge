
# Stage 1: MediaElch AppImage (amd64). Also fetches the license for every arch.
# UNVERIFIED: ubuntu:26.04 base digest is the one used by the repo apps.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS appimage

ARG VERSION
ARG TARGETARCH
ARG APPIMAGE_DATE
ARG APPIMAGE_GIT
# UNVERIFIED: no checksum is published upstream. Pin the sha256 in docker-bake.hcl (APPIMAGE_SHA256).
ARG APPIMAGE_SHA256
USER root

RUN \
  echo "**** fetch license and amd64 AppImage ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl && \
  mkdir -p /out && \
  curl -fsSL -o \
    /out/COPYING \
    "https://raw.githubusercontent.com/Komet/MediaElch/v${VERSION}/COPYING" && \
  mkdir -p /out/mediaelch && \
  if [ "${TARGETARCH}" = "amd64" ]; then \
    curl -fsSL -o \
      /tmp/MediaElch.AppImage \
      "https://github.com/Komet/MediaElch/releases/download/v${VERSION}/MediaElch_linux_${VERSION}_${APPIMAGE_DATE}_git-${APPIMAGE_GIT}.AppImage" && \
    echo "${APPIMAGE_SHA256}  /tmp/MediaElch.AppImage" | sha256sum -c - && \
    chmod +x /tmp/MediaElch.AppImage && \
    cd /tmp && \
    /tmp/MediaElch.AppImage --appimage-extract && \
    rm -rf /out/mediaelch && \
    mv /tmp/squashfs-root /out/mediaelch ; \
  fi && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# Stage 2: MediaElch from source (arm64, no AppImage is published for it).
# UNVERIFIED: Ubuntu 26.04 package names for the Qt6 and MediaInfo build dependencies.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS srcbuild

ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** build mediaelch from source (arm64 only) ****" && \
  mkdir -p /out/mediaelch && \
  if [ "${TARGETARCH}" = "arm64" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      cmake \
      git \
      libmediainfo-dev \
      libquazip1-qt6-dev \
      libqt6opengl6-dev \
      libxkbcommon-dev \
      libzen-dev \
      qt6-base-dev \
      qt6-multimedia-dev \
      qt6-svg-dev \
      qt6-tools-dev && \
    git clone --depth 1 --branch "v${VERSION}" --recurse-submodules \
      https://github.com/Komet/MediaElch.git /tmp/src && \
    cmake -S /tmp/src -B /tmp/build \
      -DCMAKE_BUILD_TYPE=Release \
      -DMEDIAELCH_FORCE_QT6=ON \
      -DCMAKE_INSTALL_PREFIX=/out/mediaelch && \
    cmake --build /tmp/build -j"$(nproc)" && \
    cmake --install /tmp/build ; \
  fi && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# Final stage: the kasmvnc web desktop (Xvnc, openbox, nginx) plus MediaElch.
# UNVERIFIED: no digest pinned for the kasmvnc image; add it with `docker buildx imagetools inspect` once it is published.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: runtime package names on ubuntu 26.04; check what kasmvnc already ships first.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    mediainfo \
    libmediainfo0v5 \
    libzen0v5 \
    libqt6svg6 \
    libqt6multimedia6 \
    libquazip1-qt6-1t64 \
    fonts-noto && \
  rm -rf /var/lib/apt/lists/*

COPY --from=appimage /out/mediaelch /app/mediaelch-appimage
COPY --from=srcbuild /out/mediaelch /app/mediaelch-src
COPY --from=appimage /out/COPYING /usr/share/licenses/mediaelch/COPYING

# Wrapper: prefer the source build when present, otherwise run the AppImage contents.
RUN \
  echo "**** install mediaelch wrapper ****" && \
  printf '%s\n' \
    '#!/bin/sh' \
    'if [ -x /app/mediaelch-src/bin/mediaelch ]; then' \
    '  exec /app/mediaelch-src/bin/mediaelch "$@"' \
    'fi' \
    'exec /app/mediaelch-appimage/AppRun "$@"' \
    > /usr/local/bin/mediaelch && \
  chmod 0755 /usr/local/bin/mediaelch && \
  echo "**** keep kasmvnc start script under a new name ****" && \
  mv /start.sh /usr/local/bin/kasmvnc-start.sh

ENV \
  HOME=/config \
  XDG_CONFIG_HOME=/config/.config \
  XDG_CACHE_HOME=/tmp/.cache \
  QT_QPA_PLATFORM=xcb

# copy local files (start.sh, defaults/autostart)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000 3001
VOLUME /config

WORKDIR /config
