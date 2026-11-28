FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

ENV HOME=/config

# Static Go binary from the upstream release. The release checksums.txt is checked at build time.
RUN case "${TARGETARCH}" in amd64) ARCH=x64 ;; arm64) ARCH=arm64 ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac && \
    VER="${VERSION#v}" && \
    ARCHIVE="dispatch_${VER}_linux_${ARCH}.tar.gz" && \
    cd /tmp && \
    curl -fsSLO "https://github.com/khlieng/dispatch/releases/download/${VERSION}/${ARCHIVE}" && \
    curl -fsSLO "https://github.com/khlieng/dispatch/releases/download/${VERSION}/checksums.txt" && \
    grep " ${ARCHIVE}\$" checksums.txt | sha256sum -c - && \
    tar xzf "${ARCHIVE}" -C /app dispatch && \
    rm -f "${ARCHIVE}" checksums.txt && \
    mkdir -p /usr/share/licenses/dispatch && \
    curl -fsSL -o /usr/share/licenses/dispatch/LICENSE "https://raw.githubusercontent.com/khlieng/dispatch/${VERSION}/LICENSE" && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
