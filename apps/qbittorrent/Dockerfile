

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d5ee44265ccc73d87135ab858d4cf4e793603f0efe7180d8b44acfe3af54db42
ARG TARGETARCH
ARG QBARCH=${TARGETARCH/arm64/aarch64}
ARG QBARCH=${QBARCH/amd64/x86_64}
ARG VERSION

# renovate: datasource=github-releases depName=ludviglundgren/qbittorrent-cli
ARG QBITORRENT_CLI_VERSION=v2.2.0

ENV QBT_CONFIRM_LEGAL_NOTICE=1 \
    HOME="/config" \
    XDG_CONFIG_HOME="/config" \
    XDG_DATA_HOME="/config"

USER root
WORKDIR /app

# Install dependencies and download binaries
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        p7zip-full \
    && rm -rf /var/lib/apt/lists/*; \
    \
    mkdir -p /app; \
    LIBTORRENT=$(curl -sL "https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/dependency-version.json" | jq -r '.libtorrent_2_0'); \
    curl -fsSL -o /app/qbittorrent-nox "https://github.com/userdocs/qbittorrent-nox-static/releases/download/release-${VERSION}_v${LIBTORRENT}/${QBARCH}-qbittorrent-nox"; \
    chown root:root /app/qbittorrent-nox; \
    chmod 755 /app/qbittorrent-nox; \
    \
    curl -fsSL "https://github.com/ludviglundgren/qbittorrent-cli/releases/download/${QBITORRENT_CLI_VERSION}/qbittorrent-cli_${QBITORRENT_CLI_VERSION#*v}_linux_${TARGETARCH}.tar.gz" \
        | tar xzf - -C /usr/local/bin; \
    rm -rf /tmp/*

# Copy local files
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:22e6e76f2f2372a7cd6e046b10025e8bde8a04a2b2b2c6072fca6821da5747f7 /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
COPY container-test.yaml /container-test.yaml
WORKDIR /config
