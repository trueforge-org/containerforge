

FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232
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
    # flask-compress>=1.18 needs zstd, but the python base image is built without _zstd
    uv pip install --pre "pyload-ng[all]==${VERSION}" "flask-compress<1.18"; \
    \
    # Create required directories with correct permissions
    mkdir -p /config /downloads; \
    chown -R 568:568 /config /downloads; \
    \
    # Clean up temporary files
    rm -rf /root/.cache /tmp/*

# Copy local files

# Copy unrar binary from LinuxServer image
COPY --from=ghcr.io/linuxserver/unrar:latest@sha256:48c0ce2609bb3c35764956bbd9395e95b177421e3c74b3628c3676029f24f2e0 /usr/bin/unrar-ubuntu /usr/bin/unrar

USER apps
COPY --chmod=0755 . /
WORKDIR /config
