FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# Prebuilt static Go binary from the upstream release tarball, verified against
# the release checksum file. Unknown architectures fail the build.
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) arch=x86_64 ;; \
      arm64) arch=arm64 ;; \
      *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    base="https://github.com/bitmagnet-io/bitmagnet/releases/download/v${VERSION}"; \
    file="bitmagnet_${VERSION}_linux_${arch}.tar.gz"; \
    mkdir -p /app/bitmagnet /tmp/bitmagnet-dl; \
    curl -fsSL -o "/tmp/bitmagnet-dl/${file}" "${base}/${file}"; \
    curl -fsSL -o /tmp/bitmagnet-dl/checksums.txt "${base}/bitmagnet_${VERSION}_checksums.txt"; \
    (cd /tmp/bitmagnet-dl && grep " ${file}\$" checksums.txt | sha256sum -c -); \
    tar -xzf "/tmp/bitmagnet-dl/${file}" -C /app/bitmagnet bitmagnet; \
    chmod 0755 /app/bitmagnet/bitmagnet; \
    mkdir -p /usr/share/licenses/bitmagnet; \
    curl -fsSL -o /usr/share/licenses/bitmagnet/LICENSE "https://raw.githubusercontent.com/bitmagnet-io/bitmagnet/v${VERSION}/LICENSE"; \
    chown -R apps:apps /app/bitmagnet; \
    rm -rf /tmp/bitmagnet-dl

USER apps
COPY --chmod=0755 . /

# 3333: web UI and API. 3334: BitTorrent (tcp and udp).
EXPOSE 3333 3334
VOLUME /config
