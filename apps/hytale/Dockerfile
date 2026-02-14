

FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:fb94cc7d837ea84061c59ae0045af491380ab095c4b77505046bd5cd37d95ca1
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