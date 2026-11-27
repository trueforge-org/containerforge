FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

# Static Go binary from the upstream release tarball, verified against the
# release checksum file. The example config is taken from the same tag, as the
# upstream Dockerfile does, and seeded to /config by start.sh.
# UNVERIFIED: asset and checksum file names for this tag follow the 5.10.1 pattern.
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64|arm64) ;; \
      *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    base="https://github.com/unpoller/unpoller/releases/download/v${VERSION}"; \
    raw="https://raw.githubusercontent.com/unpoller/unpoller/v${VERSION}"; \
    file="unpoller_${VERSION}_linux_${TARGETARCH}.tar.gz"; \
    mkdir -p /app/unpoller /etc/unpoller /tmp/unpoller-dl /usr/share/licenses/unpoller; \
    curl -fsSL -o "/tmp/unpoller-dl/${file}" "${base}/${file}"; \
    curl -fsSL -o /tmp/unpoller-dl/checksums.txt "${base}/unpoller_${VERSION}_checksums.txt"; \
    (cd /tmp/unpoller-dl && grep " ${file}\$" checksums.txt | sha256sum -c -); \
    tar -xzf "/tmp/unpoller-dl/${file}" -C /app/unpoller unpoller; \
    chmod 0755 /app/unpoller/unpoller; \
    curl -fsSL -o /etc/unpoller/up.conf "${raw}/examples/up.conf.example"; \
    curl -fsSL -o /usr/share/licenses/unpoller/LICENSE "${raw}/LICENSE"; \
    chown -R apps:apps /app; \
    chmod -R 755 /app; \
    rm -rf /tmp/unpoller-dl

USER apps
COPY --chmod=0755 . /

EXPOSE 9130
VOLUME /config
