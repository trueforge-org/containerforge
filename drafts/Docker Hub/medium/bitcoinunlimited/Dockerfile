FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config \
    PATH=/app/bin:$PATH

# Prebuilt BCH Unlimited binaries from the BitcoinUnlimitedWebDownloads repo. The checksum comes from the
# sign_<version>.json published next to them, and the build fails if it is missing.
RUN \
  echo "**** install bitcoin unlimited ${VERSION} ****" && \
  case "${TARGETARCH}" in \
    amd64) bu_arch=linux64 ;; \
    arm64) bu_arch=arm64 ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  base="https://github.com/BitcoinUnlimited/BitcoinUnlimitedWebDownloads/raw/master" && \
  curl -fsSL -o /tmp/bu.tar.gz "${base}/bch-unlimited-${VERSION}-${bu_arch}.tar.gz" && \
  curl -fsSL -o /tmp/sign.json \
    "https://raw.githubusercontent.com/BitcoinUnlimited/BitcoinUnlimitedWebDownloads/master/sign_${VERSION}.json" && \
  expected="$(grep "bch-unlimited-${VERSION}-${bu_arch}.tar.gz'" /tmp/sign.json | sed -E "s/.*: '([0-9a-f]{64})'.*/\1/")" && \
  [ -n "${expected}" ] && \
  echo "${expected}  /tmp/bu.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/bu.tar.gz -C /tmp && \
  mkdir -p /app/bin /usr/share/licenses/bitcoinunlimited /config && \
  cp "/tmp/bch-unlimited-${VERSION}/bin/bitcoind" \
     "/tmp/bch-unlimited-${VERSION}/bin/bitcoin-cli" \
     "/tmp/bch-unlimited-${VERSION}/bin/bitcoin-tx" /app/bin/ && \
  curl -fsSL -o /usr/share/licenses/bitcoinunlimited/COPYING \
    "https://gitlab.com/bitcoinunlimited/BCHUnlimited/-/raw/BCHunlimited${VERSION}/COPYING" && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app /config && \
  chmod -R 755 /app && \
  rm -rf /tmp/*

# UNVERIFIED: the tarball's lib/ (libbitcoin*) is not copied; bitcoind is expected to need only libc.
# Add it with LD_LIBRARY_PATH if ldd shows otherwise.
# UNVERIFIED: arm64 binary libc requirements were not inspected.

USER apps
COPY --chmod=0755 . /

EXPOSE 8333 8332

VOLUME /config
