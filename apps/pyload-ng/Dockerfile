

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:87a0f5a9d93409b66626a7de1e66fe7c4d9e1fd037cd4c86e91cc293ebfde78a
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
    chown -R 568:568 /config /downloads; \
    \
    # Clean up temporary files
    rm -rf /root/.cache /tmp/*

# Copy local files
COPY . /

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest /usr/bin/unrar-alpine /usr/bin/unrar

USER apps:apps
WORKDIR /config
