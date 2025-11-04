# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:462920f87d68208b7203ce499c21a3848dbf1ff90e726538027b40c414bd7ff9
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
COPY --from=ghcr.io/linuxserver/unrar:latest /usr/bin/unrar-alpine /usr/bin/unrar

USER nobody:nogroup
WORKDIR /config
