

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:0c2ff68fa63566e2fcbe025b58c229a612b4eba0377a0dc77b4b820a7d0c2ffd
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
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:92b4d32099ca9c9290bed83b4ba7cad5b0f563fd3e3bc63ca6a924b6f8a9245b /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
WORKDIR /config
