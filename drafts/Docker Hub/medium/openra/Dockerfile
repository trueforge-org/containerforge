FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# Only amd64 is built here. The AppImage bundles its own runtime libraries, so no apt runtime packages are installed.
# UNVERIFIED: the arm64 source build (dotnet SDK package, make target) is not written yet.
# UNVERIFIED: no published checksum for the AppImage. Decide whether to pin one before the PR.
RUN \
  echo "**** install openra ${VERSION} ****" && \
  case "${TARGETARCH}" in \
    amd64) ;; \
    *) echo "unsupported arch ${TARGETARCH}: only amd64 is verified, arm64 source build is UNVERIFIED" >&2; exit 1 ;; \
  esac && \
  mkdir -p /app /tmp/openra && \
  curl -fsSL -o /tmp/openra/OpenRA.AppImage \
    "https://github.com/OpenRA/OpenRA/releases/download/${VERSION}/OpenRA-Red-Alert-x86_64.AppImage" && \
  chmod +x /tmp/openra/OpenRA.AppImage && \
  cd /tmp/openra && \
  ./OpenRA.AppImage --appimage-extract && \
  mv /tmp/openra/squashfs-root /app/openra

# UNVERIFIED: launch-dedicated.sh location inside the extracted tree, and whether the extracted tree is the
# game content the server needs. Confirm in the first run.
RUN \
  echo "**** license and permissions ****" && \
  mkdir -p /usr/share/licenses/openra /config && \
  curl -fsSL -o /usr/share/licenses/openra/COPYING \
    "https://raw.githubusercontent.com/OpenRA/OpenRA/${VERSION}/COPYING" && \
  chown apps:apps /config && \
  chown -R root:root /app/openra && \
  chmod -R 755 /app/openra && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 1234

VOLUME /config

WORKDIR /app/openra
