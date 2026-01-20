

FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:b4f73313b9b6d463299c20f4b7abbb10fabdff8723fe4fec43023f564ee45f05
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

# Ensure unzip & rsync exists (safe even if already installed)
RUN set -eux; \
    command -v unzip >/dev/null 2>&1 || command -v rsync >/dev/null 2>&1 || ( \
        apt-get update && \
        apt-get install -y --no-install-recommends unzip rsync && \
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