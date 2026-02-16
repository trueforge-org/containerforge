

FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:f48b29b26b1c135270955a9cd5182cabbf2fbff77c5bab69bb51658c9bf856ff
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

# Ensure unzip & rsync exists (safe even if already installed)
RUN set -eux; \
    missing=""; \
    command -v curl >/dev/null 2>&1 || missing="$missing curl"; \
    command -v unzip >/dev/null 2>&1 || missing="$missing unzip"; \
    command -v rsync >/dev/null 2>&1 || missing="$missing rsync"; \
    [ -n "$missing" ] && ( \
        apt-get update && \
        apt-get install -y --no-install-recommends $missing && \
        rm -rf /var/lib/apt/lists/* \
    )


# Install runtime downloader wrapper
COPY hytale-downloader /usr/local/bin/hytale-downloader
RUN chmod +x /usr/local/bin/hytale-downloader

# Copy application files with correct ownership
COPY . /

USER apps
