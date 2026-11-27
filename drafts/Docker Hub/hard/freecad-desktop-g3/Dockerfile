
# UNVERIFIED: no digest is in plan.md. Pin the digest of ghcr.io/trueforge-org/kasmvnc:1.5.2 before the first build.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:7e96ef6465ad32c153f71fdff80fa4e2cb8fdfce1ab79dd269f08c7647505275

ARG VERSION
ARG TARGETARCH
ARG FREECAD_SHA256_AMD64
ARG FREECAD_SHA256_ARM64
USER root

# libpci3 and the Mesa GL libraries come with the kasmvnc base (pciutils and mesa), so they are not installed again.
RUN echo "*** Installing FreeCAD runtime libraries ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libglu1-mesa \
    libxss1 \
    libxtst6 \
    mesa-utils && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# The AppImage is extracted at build time, so neither FUSE nor writes under /app are needed at runtime.
# UNVERIFIED: the x86_64 AppImage name and the checksum values (see docker-bake.hcl). Renovate tracks the tag.
RUN echo "*** Installing FreeCAD ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) FC_ARCH=x86_64 FC_SHA256="${FREECAD_SHA256_AMD64}" ;; \
    arm64) FC_ARCH=aarch64 FC_SHA256="${FREECAD_SHA256_ARM64}" ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fL -o /tmp/FreeCAD.AppImage \
    "https://github.com/FreeCAD/FreeCAD/releases/download/${VERSION}/FreeCAD_${VERSION}-Linux-${FC_ARCH}-py311.AppImage" && \
  echo "${FC_SHA256}  /tmp/FreeCAD.AppImage" | sha256sum -c - && \
  chmod +x /tmp/FreeCAD.AppImage && \
  cd /tmp && /tmp/FreeCAD.AppImage --appimage-extract > /dev/null && \
  rm -rf /app/freecad && \
  mv /tmp/squashfs-root /app/freecad && \
  ln -s /app/freecad/AppRun /usr/local/bin/freecad && \
  echo "*** Collecting licenses ***" && \
  mkdir -p /usr/share/licenses/freecad && \
  find /app/freecad -maxdepth 3 -type f \( -iname 'LICENSE*' -o -iname 'COPYING*' \) \
    -exec cp {} /usr/share/licenses/freecad/ \; && \
  chmod -R a+rX /app && \
  rm -rf /tmp/*

# XDG_CONFIG_HOME is deliberately not changed: the kasmvnc base uses /config for openbox.
ENV LIBGL_ALWAYS_SOFTWARE=1

# defaults/autostart replaces the kasmvnc default autostart (xterm) with FreeCAD.
USER apps
COPY --chmod=0755 . /

EXPOSE 3000 3001

VOLUME /config
