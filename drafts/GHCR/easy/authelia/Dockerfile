FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH

USER root

ENV HOME=/config \
    PATH=/app/authelia:${PATH} \
    X_AUTHELIA_CONFIG=/config/configuration.yml

# The release ships a tarball per architecture with a checksums.sha256 file. Only amd64 and arm64 are published.
# UNVERIFIED: the tar member layout, so the binary is located with find. Check it on the first build.
# The release signature (checksums.sha256.sig) is not verified here.
RUN echo "*** Installing Authelia ${VERSION} ***" && \
    case "${TARGETARCH}" in amd64|arm64) ;; *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; esac && \
    mkdir -p /tmp/authelia-dl/extract && \
    cd /tmp/authelia-dl && \
    asset="authelia-v${VERSION}-linux-${TARGETARCH}-musl.tar.gz" && \
    base="https://github.com/authelia/authelia/releases/download/v${VERSION}" && \
    curl -fsSL -o "${asset}" "${base}/${asset}" && \
    curl -fsSL -o checksums.sha256 "${base}/checksums.sha256" && \
    grep " ${asset}\$" checksums.sha256 | sha256sum -c - && \
    tar -xzf "${asset}" -C extract && \
    authelia_bin="$(find extract -type f -name authelia -print -quit)" && \
    test -n "${authelia_bin}" && \
    mkdir -p /app/authelia && \
    install -m 0755 "${authelia_bin}" /app/authelia/authelia && \
    echo "*** Installing license ***" && \
    mkdir -p /usr/share/licenses/authelia && \
    curl -fsSL -o /usr/share/licenses/authelia/LICENSE "https://raw.githubusercontent.com/authelia/authelia/v${VERSION}/LICENSE" && \
    chown -R apps:apps /app && chmod -R 755 /app && \
    mkdir -p /config && chown apps:apps /config && \
    echo "*** Cleaning Up ***" && \
    cd / && rm -rf /tmp/authelia-dl

USER apps
COPY --chmod=0755 . /

EXPOSE 9091

VOLUME /config

CMD ["/start.sh"]
