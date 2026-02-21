

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:8ba5cf93d8f36593fc5dcc55bdccc40f581008ab4732dca1f7c520daae9f145b
ARG VERSION

ENV NZBGET__PORT=6789

USER root
WORKDIR /app

# Install dependencies and NZBGet
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        p7zip-full \
        lscpu \
    && rm -rf /var/lib/apt/lists/*; \
    \
    curl -fsSL -o /tmp/nzbget.run \
        "https://github.com/nzbgetcom/nzbget/releases/download/v${VERSION}/nzbget-${VERSION}-bin-linux.run"; \
    sh /tmp/nzbget.run --destdir /app; \
    rm -rf /app/7za /app/unrar /app/unrar7; \
    \
    pip install uv; \
    uv pip install apprise pynzb requests; \
    chown -R root:root /app && chmod -R 755 /app; \
    pip uninstall --yes uv; \
    rm -rf /root/.cache /root/.cargo /tmp/*

# Copy local files

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:22e6e76f2f2372a7cd6e046b10025e8bde8a04a2b2b2c6072fca6821da5747f7 /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
COPY --chmod=0755 . /
WORKDIR /config
