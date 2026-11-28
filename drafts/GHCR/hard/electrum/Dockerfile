FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION=4.8.4

USER root

# Fetch the source of the git tag only. The tag commit is 460c117c4f4a6ae2e1dc13f2934b14fac6a1b9d9.
# UNVERIFIED: no published checksum for the archive; record one before shipping.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /tmp/electrum-src \
 && curl -fsSL -o /tmp/electrum.tar.gz \
      "https://github.com/spesmilo/electrum/archive/refs/tags/${VERSION}.tar.gz" \
 && tar xzf /tmp/electrum.tar.gz -C /tmp/electrum-src --strip-components=1 \
 && rm -f /tmp/electrum.tar.gz


FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION=4.8.4

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/.cache \
    DATA_DIR=/config/electrum \
    DISPLAY=:99 \
    CUSTOM_RES_W=1024 \
    CUSTOM_RES_H=768 \
    CUSTOM_DEPTH=16 \
    NOVNC_PORT=6080

USER root

# UNVERIFIED: package names and availability on ubuntu 26.04 (amd64 and arm64).
# Pin versions once confirmed. Upstream ich777 image takes Qt from apt only.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      python3-venv \
      python3-pyqt5 \
      python3-cryptography \
      libsecp256k1-2 \
      xvfb \
      fluxbox \
      x11vnc \
      novnc \
      websockify \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/electrum-src /tmp/electrum-src

# Electrum is installed into a venv that sees the apt PyQt5. /app stays read-only at runtime.
# UNVERIFIED: install path (no release assets for 4.8.4; install from the source tree) and
# that the upstream source ships the licence file as LICENCE.
RUN mkdir -p /app /usr/share/licenses/electrum \
 && python3 -m venv --system-site-packages /app/venv \
 && /app/venv/bin/pip install --no-cache-dir /tmp/electrum-src \
 && install -Dm644 /tmp/electrum-src/LICENCE /usr/share/licenses/electrum/LICENSE \
 && rm -rf /tmp/electrum-src \
 && chmod -R 755 /app /usr/share/licenses/electrum

WORKDIR /config
VOLUME ["/config"]
EXPOSE 6080

# etc/.fluxbox is not shipped: the upstream fluxbox config (ich777 conf/) was not fetched.
COPY --chmod=0755 . /

USER apps
