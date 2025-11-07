# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:eb8c395317bd3e807501ef61f4d16a9582b11db2e28c46e74d1dd6c9762002a4
ARG VERSION

ENV HOME="/config"

USER root
WORKDIR /app

# Install runtime and build dependencies
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        libcurl4-openssl-dev \
        ffmpeg \
        libatomic1 \
        libjpeg-turbo8-dev \
        p7zip-full \
        sqlite3 \
        tesseract-ocr \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*; \
    \
    # Install Python packages
    pip install --no-cache-dir uv; \
    uv pip install --pre "pyload-ng[all]==${VERSION}"; \
    \
    # Create required directories with correct permissions
    mkdir -p /config /downloads; \
    chown -R nobody:nogroup /config /downloads; \
    \
    # Clean up temporary files
    rm -rf /root/.cache /tmp/*

# Copy local files
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest /usr/bin/unrar-alpine /usr/bin/unrar

USER nobody:nogroup
WORKDIR /config
