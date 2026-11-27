# hadolint ignore=DL3007
# Row is the rtorrent_exporter sidecar only. The main rtorrent-rutorrent image needs its own draft.
# UNVERIFIED: tarball member layout (binary at archive root) and whether it ships a LICENSE file; confirm on first build.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH

USER root

RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64|arm64) ;; \
        *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    mkdir -p /tmp/rtorrent-exporter; \
    cd /tmp/rtorrent-exporter; \
    BASE_URL="https://github.com/thde/rtorrent_exporter/releases/download/v${VERSION}"; \
    ASSET="rtorrent_exporter_${VERSION}_linux_${TARGETARCH}.tar.gz"; \
    CHECKSUMS="rtorrent_exporter_${VERSION}_checksums.txt"; \
    curl -fsSLO "${BASE_URL}/${ASSET}"; \
    curl -fsSLO "${BASE_URL}/${CHECKSUMS}"; \
    grep " ${ASSET}\$" "${CHECKSUMS}" | sha256sum -c -; \
    tar -xzf "${ASSET}"; \
    install -m 0755 rtorrent_exporter /app/rtorrent_exporter; \
    if [ -f LICENSE ]; then install -Dm0644 LICENSE /usr/share/licenses/rtorrent-exporter/LICENSE; fi; \
    chown -R apps:apps /app; \
    cd /; \
    rm -rf /tmp/rtorrent-exporter /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 9135

CMD ["/start.sh"]
