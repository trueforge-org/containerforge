# Fetch stage: download the self-contained release zip and verify it.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS fetch

ARG VERSION
ARG TARGETARCH
ARG SHA256_X64
ARG SHA256_ARM64

USER root

# UNVERIFIED: upstream publishes no checksum. SHA256_X64 and SHA256_ARM64 must be computed locally
# from the release zips and set in docker-bake.hcl. The build fails while they are empty.
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) ARCH=x64; SHA="${SHA256_X64}" ;; \
        arm64) ARCH=arm64; SHA="${SHA256_ARM64}" ;; \
        *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    test -n "${SHA}" || { echo "missing SHA256 for ${TARGETARCH}" >&2; exit 1; }; \
    apt-get update; \
    apt-get install -y --no-install-recommends unzip; \
    rm -rf /var/lib/apt/lists/*; \
    curl -fsSL -o /tmp/slskd.zip "https://github.com/slskd/slskd/releases/download/${VERSION}/slskd-${VERSION}-linux-${ARCH}.zip"; \
    echo "${SHA}  /tmp/slskd.zip" | sha256sum -c -; \
    unzip -q /tmp/slskd.zip -d /tmp/slskd; \
    rm -f /tmp/slskd.zip; \
    curl -fsSL -o /tmp/LICENSE "https://raw.githubusercontent.com/slskd/slskd/${VERSION}/LICENSE"

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# UNVERIFIED: the upstream image sets SLSKD_APP_DIR=/app, while docs/config.md calls the variable APP_DIR.
# /config is used here. The release zip bundles the .NET runtime; it is extracted to /tmp at start.
ENV SLSKD_APP_DIR=/config \
    SLSKD_HTTP_PORT=5030 \
    SLSKD_HTTPS_PORT=5031 \
    SLSKD_SLSK_LISTEN_PORT=50300 \
    SLSKD_UMASK=0022 \
    DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp/.net \
    DOTNET_EnableDiagnostics=0 \
    DOTNET_gcServer=0 \
    DOTNET_gcConcurrent=1 \
    DOTNET_GCHeapHardLimit=0x80000000 \
    DOTNET_GCConserveMemory=9 \
    HOME=/config

USER root

COPY --from=fetch /tmp/slskd /app
COPY --from=fetch /tmp/LICENSE /usr/share/licenses/slskd/LICENSE

RUN chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 5030 5031 50300

VOLUME /config

CMD ["/start.sh"]
