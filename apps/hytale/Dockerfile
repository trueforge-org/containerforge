

FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:3dcc3669a0e1233a9effba12e205cf7a3687d07254d9ef59b65c98c15548d886
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