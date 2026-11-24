FROM ghcr.io/trueforge-org/qbittorrent:5.3.1@sha256:424c9abe318868d4c4d0f5d368795c920e5877d753d710b4b35a3ab342e69b05

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
