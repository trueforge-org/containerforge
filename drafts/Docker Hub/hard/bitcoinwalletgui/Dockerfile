
# UNVERIFIED: no digest pinned for ghcr.io/trueforge-org/kasmvnc. Resolve it with `docker buildx imagetools inspect` and pin it before merging.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  XDG_CACHE_HOME=/tmp/cache \
  QT_QPA_PLATFORM=xcb

# UNVERIFIED: this Qt xcb set is inferred. Confirm with `ldd bin/bitcoin-qt` after the first extract and drop what the base already has.
RUN echo "*** Installing Qt runtime libraries ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libgl1 \
    libfontconfig1 \
    libxcb-cursor0 \
    libxcb-xinerama0 \
    libxkbcommon-x11-0 && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: the tarball layout (bin/, share/ and COPYING after --strip-components=1) is not confirmed for 32.x.
# Checksum: the line for this tarball is checked against the upstream SHA256SUMS file.
RUN echo "*** Installing Bitcoin Core ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) BTC_ARCH="x86_64-linux-gnu" ;; \
    arm64) BTC_ARCH="aarch64-linux-gnu" ;; \
    *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
  esac && \
  mkdir -p /app /tmp/btc && \
  cd /tmp/btc && \
  curl -fsSL -o bitcoin.tar.gz "https://bitcoincore.org/bin/bitcoin-core-${VERSION}/bitcoin-${VERSION}-${BTC_ARCH}.tar.gz" && \
  curl -fsSL -o SHA256SUMS "https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS" && \
  grep -F "bitcoin-${VERSION}-${BTC_ARCH}.tar.gz" SHA256SUMS | sha256sum -c - && \
  tar xzf bitcoin.tar.gz --strip-components=1 -C /app && \
  mkdir -p /usr/share/licenses/bitcoinwalletgui && \
  cp /app/COPYING /usr/share/licenses/bitcoinwalletgui/COPYING && \
  cd / && \
  rm -rf /tmp/btc && \
  chown -R apps:apps /app

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 3001

VOLUME /config
