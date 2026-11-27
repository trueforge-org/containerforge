FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV GPODDER_HOME=/config \
    GPODDER_DOWNLOAD_DIR=/downloads

# UNVERIFIED: this is the headless core only. The upstream image is a selkies GUI desktop, which has no ContainerForge base.
# UNVERIFIED: gPodder installs from source with pip into the bundled /app/venv; confirm the console script and dependencies resolve.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg && \
  echo "**** install gpodder ${VERSION} ****" && \
  mkdir -p /tmp/gpodder-src && \
  curl -fL -o \
    /tmp/gpodder.tar.gz \
    "https://github.com/gpodder/gpodder/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/gpodder.tar.gz -C \
    /tmp/gpodder-src --strip-components=1 && \
  PIP_CACHE_DIR=/tmp/pip /app/venv/bin/pip install --no-cache-dir /tmp/gpodder-src && \
  mkdir -p /usr/share/licenses/gpodder && \
  cp /tmp/gpodder-src/COPYING /usr/share/licenses/gpodder/COPYING && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /

# volumes
VOLUME /config
VOLUME /downloads

WORKDIR /config
