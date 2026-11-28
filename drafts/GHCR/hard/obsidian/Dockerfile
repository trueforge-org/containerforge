FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# HOME moves off /vaults (upstream sets HOME=/vaults). Electron caches go to /tmp.
# XDG_CONFIG_HOME=/config keeps Obsidian settings on the persistent volume.
ENV \
  HOME=/tmp \
  XDG_CACHE_HOME=/tmp/cache \
  XDG_CONFIG_HOME=/config

# UNVERIFIED: package list for the GUI stack. Electron also needs GTK and audio libraries.
# Confirm names against the 26.04 archive and pin them at build time.
RUN echo "*** Installing display and web front end packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libnss3 \
    xvfb \
    x11vnc \
    novnc \
    websockify && \
  rm -rf /var/lib/apt/lists/*

# Only amd64 is supported: the upstream image downloads an x86_64 AppImage.
# UNVERIFIED: the 1.x asset name Obsidian-${VERSION}.AppImage (the draft's names are not confirmed).
# No upstream checksum is published. Extract at build time so no FUSE is needed at runtime.
RUN echo "*** Installing Obsidian ${VERSION} ***" && \
  [ "${TARGETARCH}" = "amd64" ] || { echo "unsupported arch ${TARGETARCH}"; exit 1; } && \
  mkdir -p /app && \
  curl -fsSL -o /tmp/obsidian.AppImage \
    "https://github.com/obsidianmd/obsidian-releases/releases/download/v${VERSION}/Obsidian-${VERSION}.AppImage" && \
  chmod +x /tmp/obsidian.AppImage && \
  cd /tmp && /tmp/obsidian.AppImage --appimage-extract && \
  mv /tmp/squashfs-root /app/obsidian && \
  chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/obsidian.AppImage
# UNVERIFIED: the Obsidian license is not stated anywhere fetched, so no license file is shipped yet.

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
VOLUME /vaults
