FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config \
  XDG_CACHE_HOME=/tmp/.cache \
  SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# UNVERIFIED: upstream publishes no checksum for the AppImage. The sha256 values
# below are placeholders and must be computed from the downloaded asset and pinned
# (see plan section 10). The build fails until they are replaced.
RUN echo "*** Installing OrcaSlicer ***" && \
  case "$TARGETARCH" in \
    amd64) ORCA_ARCH=""; ORCA_SHA256="PIN-SHA256-AMD64" ;; \
    arm64) ORCA_ARCH="aarch64_"; ORCA_SHA256="PIN-SHA256-ARM64" ;; \
    *) echo "unsupported arch $TARGETARCH" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/orca.AppImage \
    "https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v${VERSION}/OrcaSlicer_Linux_AppImage_Ubuntu2404_${ORCA_ARCH}V${VERSION}.AppImage" && \
  echo "${ORCA_SHA256}  /tmp/orca.AppImage" | sha256sum -c - && \
  cd /tmp && \
  chmod +x orca.AppImage && \
  ./orca.AppImage --appimage-extract && \
  mv squashfs-root /app/orcaslicer && \
  rm -f /tmp/orca.AppImage && \
  sed -i "1a export GDK_BACKEND=x11" /app/orcaslicer/AppRun && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/orcaslicer && \
  curl -fsSL -o /usr/share/licenses/orcaslicer/LICENSE \
    "https://raw.githubusercontent.com/OrcaSlicer/OrcaSlicer/v${VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app/orcaslicer && chmod -R 755 /app/orcaslicer

# UNVERIFIED: a display stack (Xvfb plus a remote-desktop server) is not chosen yet.
# Ubuntu 26.04 package names for any GUI libraries are UNVERIFIED. Run ldd on
# /app/orcaslicer/bin/orca-slicer and add only what is reported missing.

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 3001
VOLUME /config
