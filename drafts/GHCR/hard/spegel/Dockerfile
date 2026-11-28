FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

# Prebuilt static Go binary from the release. Checksums are from spegel_0.8.1_checksums.txt (plan section 1).
# Only amd64 and arm64 are pinned. 32-bit arm is not enabled.
# UNVERIFIED: the tarball contains a top-level `spegel` binary (extracted alone, so anything else is skipped).
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) sha256=3e2d2886f1cc846f3439156dea9a4bd003b73fc9ee9e8f96462c153add71f049 ;; \
      arm64) sha256=469de3a23b37cc7bbac33bb64d2fa2135bacab42b4b231d9d545a4affdd6b9f5 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/spegel.tar.gz \
      "https://github.com/spegel-org/spegel/releases/download/v${VERSION}/spegel_${VERSION}_linux_${TARGETARCH}.tar.gz"; \
    echo "${sha256}  /tmp/spegel.tar.gz" | sha256sum -c -; \
    mkdir -p /app; \
    tar -xzf /tmp/spegel.tar.gz -C /app spegel; \
    chmod 0755 /app/spegel; \
    rm -f /tmp/spegel.tar.gz

# UNVERIFIED: the release tarball ships a LICENSE. Copy it to /usr/share/licenses/spegel/ once confirmed.

ENV TMPDIR=/tmp

# Binary stays owned by root and is read-only at runtime.
RUN set -eux; \
    chown -R root:root /app; \
    chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

# No ports are exposed yet: the spegel registry and metrics ports were not confirmed from the CLI flags or docs.
# Host access (containerd socket, content path, registry config path) is a deployment concern, not part of the image.
ENTRYPOINT ["/start.sh"]
