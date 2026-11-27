# UNVERIFIED (initial draft): the release zip layout, the Qt5 and VNC package names on ubuntu 26.04 and the
# binary names have not been checked by a build. arm64 is not built: upstream has no arm64 release asset.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: SHA-256 of tsMuxer-${VERSION}-linux.zip. Not published upstream. Compute it from a trusted
# download and fill it in before the build. The build fails until it is set.
ARG SHA256_TSMUXER_AMD64=""
USER root

RUN case "${TARGETARCH}" in amd64) ;; *) echo "tsmuxer: no upstream build for ${TARGETARCH}" >&2; exit 1 ;; esac

# UNVERIFIED: Qt5 and Ubuntu 26.04 package names, and the desktop and VNC stack
RUN \
  echo "*** Installing desktop and VNC runtime ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip \
    xvfb \
    x11vnc \
    xkb-data \
    libqt5gui5 \
    libqt5widgets5 \
    libqt5multimedia5 \
    fonts-croscore \
    adwaita-qt && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo "*** Installing tsMuxer ${VERSION} ***" && \
  curl -fL -o /tmp/tsmuxer.zip \
    "https://github.com/justdan96/tsMuxer/releases/download/${VERSION}/tsMuxer-${VERSION}-linux.zip" && \
  echo "${SHA256_TSMUXER_AMD64}  /tmp/tsmuxer.zip" | sha256sum -c - && \
  mkdir -p /app/tsmuxer && \
  unzip -q /tmp/tsmuxer.zip -d /app/tsmuxer && \
  chmod -R 0755 /app/tsmuxer && \
  rm -f /tmp/tsmuxer.zip

# The release zip is binaries only, so the licence comes from the source tarball of the same tag.
RUN \
  echo "*** Installing licence ***" && \
  mkdir -p /usr/share/licenses/tsmuxer && \
  curl -fL "https://github.com/justdan96/tsMuxer/archive/refs/tags/${VERSION}.tar.gz" \
    | tar -xz -C /tmp --wildcards '*/LICENSE' && \
  install -m 0644 /tmp/tsMuxer-*/LICENSE /usr/share/licenses/tsmuxer/LICENSE && \
  rm -rf /tmp/tsMuxer-*

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/cache \
    XDG_RUNTIME_DIR=/tmp/runtime

RUN mkdir -p /config && chown apps:apps /config

USER apps
COPY --chmod=0755 . /

EXPOSE 5900
VOLUME /config
VOLUME /storage
