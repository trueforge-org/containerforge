
# UNVERIFIED: no digest pinned for ghcr.io/trueforge-org/kasmvnc. Resolve it with `docker buildx imagetools inspect` and pin it before merging.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  XDG_CACHE_HOME=/tmp/cache \
  XDG_DOWNLOAD_DIR=/prints \
  QT_QPA_PLATFORM=xcb \
  LIBGL_ALWAYS_SOFTWARE=1 \
  MESA_GL_VERSION_OVERRIDE=4.5

# UNVERIFIED: these Qt 6 xcb runtime libraries are inferred. Remove any the kasmvnc base already has once a run confirms it.
RUN echo "*** Installing Qt runtime libraries ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libegl1 \
    libgl1 \
    libgl1-mesa-dri \
    libglu1-mesa \
    libnss3 \
    libxcb-cursor0 \
    libxcomposite1 \
    libxdamage1 \
    libxkbcommon0 \
    libxrandr2 \
    libxss1 \
    libxtst6 && \
  rm -rf /var/lib/apt/lists/*

# amd64: the upstream AppImage, extracted so no FUSE is needed. arm64: Ubuntu's cura 5.0.0 package (the AppImage is not published for arm64).
# UNVERIFIED: upstream publishes only a .asc signature, no sha256. Import the UltiMaker release key and gpg --verify it, or pin a sha256 once computed.
RUN echo "*** Installing Cura ${VERSION} ***" && \
  mkdir -p /app && \
  if [ "${TARGETARCH}" = "amd64" ]; then \
    mkdir -p /tmp/cura && \
    cd /tmp/cura && \
    curl -fsSL -o cura.AppImage "https://github.com/Ultimaker/Cura/releases/download/${VERSION}/UltiMaker-Cura-${VERSION}-linux-X64.AppImage" && \
    chmod +x cura.AppImage && \
    ./cura.AppImage --appimage-extract && \
    mv squashfs-root /app/cura && \
    sed -i 's/QT_QPA_PLATFORMTHEME=xdgdesktopportal/QT_QPA_PLATFORMTHEME=gtk3/' /app/cura/AppRun && \
    ln -s /app/cura/AppRun /usr/local/bin/cura && \
    cd / && \
    rm -rf /tmp/cura; \
  else \
    apt-get update && \
    apt-get install -y --no-install-recommends cura=5.0.0-6build1 && \
    rm -rf /var/lib/apt/lists/*; \
  fi && \
  mkdir -p /usr/share/licenses/cura-novnc && \
  curl -fsSL -o /usr/share/licenses/cura-novnc/LICENSE "https://raw.githubusercontent.com/Ultimaker/Cura/${VERSION}/LICENSE" && \
  mkdir -p /prints && \
  chown -R apps:apps /app /prints

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 3001

VOLUME /config
VOLUME /prints
