FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG RESTIC_VERSION
ARG TARGETARCH

USER root

ENV HOME=/config \
    XDG_CONFIG_HOME=/config/.config \
    XDG_DATA_HOME=/config/.local/share \
    PATH=/app/backrest:$PATH

# Backrest is a glibc release binary, so the Ubuntu base is used (the upstream alpine image is musl).
# Both downloads are verified against the checksum file published with each release.
# UNVERIFIED: the restic checksum asset name (SHA256SUMS) and the bz2 asset layout are not confirmed.
# UNVERIFIED: the backrest tarball layout (binary at archive root) is not confirmed.
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) BACKREST_ARCH=x86_64 ;; \
        arm64) BACKREST_ARCH=arm64 ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    mkdir -p /app/backrest /tmp/downloads; \
    cd /tmp/downloads; \
    curl -fsSL -o "backrest_Linux_${BACKREST_ARCH}.tar.gz" \
        "https://github.com/garethgeorge/backrest/releases/download/v${VERSION}/backrest_Linux_${BACKREST_ARCH}.tar.gz"; \
    curl -fsSL -o backrest_checksums.txt \
        "https://github.com/garethgeorge/backrest/releases/download/v${VERSION}/backrest_${VERSION}_checksums.txt"; \
    grep " backrest_Linux_${BACKREST_ARCH}\.tar\.gz\$" backrest_checksums.txt | sha256sum -c -; \
    tar -xzf "backrest_Linux_${BACKREST_ARCH}.tar.gz" -C /app/backrest; \
    curl -fsSL -o "restic_${RESTIC_VERSION}_linux_${TARGETARCH}.bz2" \
        "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_${TARGETARCH}.bz2"; \
    curl -fsSL -o restic_SHA256SUMS \
        "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/SHA256SUMS"; \
    grep " restic_${RESTIC_VERSION}_linux_${TARGETARCH}\.bz2\$" restic_SHA256SUMS | sha256sum -c -; \
    bzip2 -dc "restic_${RESTIC_VERSION}_linux_${TARGETARCH}.bz2" > /app/backrest/restic; \
    chmod 0755 /app/backrest/backrest /app/backrest/restic; \
    chown -R apps:apps /app/backrest; \
    cd /; \
    rm -rf /tmp/downloads

USER apps
COPY --chmod=0755 . /

EXPOSE 9898

VOLUME /config
