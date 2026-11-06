FROM ghcr.io/trueforge-org/qbittorrent:5.3.0@sha256:ace2c4bd3a4eb1f6a406ca328e35ea44dddd05088c94d987b57ace4c537cf0fd

ARG TARGETARCH
ARG VERSION
ARG FLOOD_VERSION

USER root
WORKDIR /app

EXPOSE 3000 8080 6881

# Install Flood next to qBittorrent. Upstream publishes no checksums for the release binaries.
RUN set -eux; \
    FLOODARCH="${TARGETARCH/amd64/x64}"; \
    curl -fsSL "https://github.com/jesec/flood/releases/download/v${FLOOD_VERSION}/flood-linux-${FLOODARCH}" -o /app/flood; \
    chown root:root /app/flood; \
    chmod 755 /app/flood

USER apps
COPY --chmod=0755 . /
WORKDIR /config
