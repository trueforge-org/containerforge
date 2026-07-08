

FROM ghcr.io/trueforge-org/python:3.14.6@sha256:ec53f98750c3acd589a038d00430d6554f2530c9888dce3b3651a943a62d43b4
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

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:5e150efdebbcb4e313b30bd17e40fc386f538a0a9baa4c9b1a5368a9a9a57e39 /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
COPY --chmod=0755 . /
WORKDIR /config
