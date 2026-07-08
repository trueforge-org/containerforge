

FROM ghcr.io/trueforge-org/python:3.14.6@sha256:ec53f98750c3acd589a038d00430d6554f2530c9888dce3b3651a943a62d43b4
ARG TARGETARCH
ARG QBARCH=${TARGETARCH/arm64/aarch64}
ARG QBARCH=${QBARCH/amd64/x86_64}
ARG VERSION

# renovate: datasource=github-releases depName=ludviglundgren/qbittorrent-cli
ARG QBITORRENT_CLI_VERSION=v2.3.0

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

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:5e150efdebbcb4e313b30bd17e40fc386f538a0a9baa4c9b1a5368a9a9a57e39 /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
COPY --chmod=0755 . /
WORKDIR /config
