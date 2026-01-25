

FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:f3d090f97bcba8ae86cd35b8d0b26e0f39cced98d0a4b772dba6717f32c654ae
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

# Ensure unzip & rsync exists (safe even if already installed)
RUN set -eux; \
    missing=""; \
    command -v unzip >/dev/null 2>&1 || missing="$missing unzip"; \
    command -v rsync >/dev/null 2>&1 || missing="$missing rsync"; \
    [ -n "$missing" ] && ( \
        apt-get update && \
        apt-get install -y --no-install-recommends $missing && \
        rm -rf /var/lib/apt/lists/* \
    )


# Download Hytale Downloader
RUN set -eux; \
    curl -fL https://downloader.hytale.com/hytale-downloader.zip -o /tmp/hytale.zip; \
    unzip -q /tmp/hytale.zip -d /tmp; \
    mv /tmp/hytale-downloader-linux-amd64 /usr/local/bin/hytale-downloader; \
    chmod +x /usr/local/bin/hytale-downloader; \
    rm -rf /tmp/hytale.zip

# Copy application files with correct ownership
COPY . /

USER apps:apps