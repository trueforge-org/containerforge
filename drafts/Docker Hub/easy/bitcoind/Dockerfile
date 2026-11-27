FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  PATH=/app/bin:${PATH}

# Verified download: SHA256SUMS from the same host (guards against corruption only, see plan section 4).
# UNVERIFIED: tarball layout (bin/, libexec/, share/ under bitcoin-<ver>/); check with tar tzf on the first build.
# UNVERIFIED: ldd completeness on the ubuntu base.
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) ARCH=x86_64 ;; \
      arm64) ARCH=aarch64 ;; \
      *) echo "unsupported ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    BASE="https://bitcoincore.org/bin/bitcoin-core-${VERSION}"; \
    FILE="bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz"; \
    cd /tmp; \
    curl -fsSLO "${BASE}/${FILE}"; \
    curl -fsSLO "${BASE}/SHA256SUMS"; \
    grep " ${FILE}\$" SHA256SUMS | sha256sum -c -; \
    tar -xzf "${FILE}" -C /app --strip-components=1; \
    rm -f /app/bin/bitcoin-qt /app/bin/test_bitcoin*; \
    mkdir -p /usr/share/licenses/bitcoind; \
    curl -fsSL -o /usr/share/licenses/bitcoind/COPYING "https://raw.githubusercontent.com/bitcoin/bitcoin/v${VERSION}/COPYING"; \
    chown -R apps:apps /app; \
    chmod -R 755 /app; \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8333 8332

VOLUME /config

WORKDIR /config
