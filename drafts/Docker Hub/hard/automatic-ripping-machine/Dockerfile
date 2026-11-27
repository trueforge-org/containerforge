
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: apt package names on this base, and the python 3.15 compatibility of ARM's requirements.txt.
# Fallback if either fails: ghcr.io/trueforge-org/ubuntu:26.04 with apt python3.
# MakeMKV is NOT bundled in this draft (plan sections 3 and 10): no build stage yet.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    handbrake-cli \
    ffmpeg \
    abcde \
    lsdvd \
    eject \
    cd-discid \
    cdparanoia \
    flac \
    imagemagick \
    git \
    libcurl4-openssl-dev \
    libudev-dev && \
  echo "**** fetch automatic-ripping-machine ****" && \
  mkdir -p /app/arm && \
  curl -fsSL -o \
    /tmp/arm.tar.gz \
    "https://github.com/automatic-ripping-machine/automatic-ripping-machine/archive/refs/tags/${VERSION}.tar.gz" && \
  # UNVERIFIED: no checksum is published upstream.
  tar xzf \
    /tmp/arm.tar.gz -C \
    /app/arm --strip-components=1 && \
  echo "**** python venv (read-only at runtime) ****" && \
  python3 -m venv /app/venv-arm && \
  PIP_CACHE_DIR=/tmp/pip /app/venv-arm/bin/pip install --no-cache-dir -r /app/arm/requirements.txt && \
  echo "**** seed config files for /config (UNVERIFIED paths in upstream setup/) ****" && \
  mkdir -p /defaults && \
  cp /app/arm/setup/arm.yaml /app/arm/setup/apprise.yaml /app/arm/setup/abcde.conf /defaults/ && \
  echo "**** license ****" && \
  mkdir -p /usr/share/licenses/automatic-ripping-machine && \
  cp /app/arm/LICENSE /usr/share/licenses/automatic-ripping-machine/LICENSE && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# copy local files (start.sh, defaults/ and other allow-listed paths)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
