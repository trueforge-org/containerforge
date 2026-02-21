

FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:8bc5c99d41e9af3831e12235c35d0286f33e07b468da38114ce94925e90b6f30
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
RUN cat <<'EOF' > /usr/local/bin/hytale-downloader
#!/usr/bin/env bash
set -euo pipefail

TMP_DIR="$(mktemp -d)"
LOG_FILE="$TMP_DIR/hytale-downloader-stderr.log"
trap 'rm -rf "$TMP_DIR"' EXIT

> "$LOG_FILE"
if ! curl -fL https://downloader.hytale.com/hytale-downloader.zip -o "$TMP_DIR/hytale.zip" 2>>"$LOG_FILE"; then
    echo "[ERROR] Failed to download hytale-downloader.zip from downloader.hytale.com" >&2
    echo "[ERROR] curl output:" >&2
    cat "$LOG_FILE" >&2 || true
    exit 1
fi

if [ -n "${HYTALE_DOWNLOADER_SHA256:-}" ]; then
    ACTUAL_SHA256="$(sha256sum "$TMP_DIR/hytale.zip" | awk '{print $1}')"
    if [ "$ACTUAL_SHA256" != "$HYTALE_DOWNLOADER_SHA256" ]; then
        echo "[ERROR] hytale-downloader.zip checksum verification failed" >&2
        exit 1
    fi
fi

if ! unzip -q "$TMP_DIR/hytale.zip" -d "$TMP_DIR" 2>>"$LOG_FILE"; then
    echo "[ERROR] Failed to extract hytale-downloader.zip" >&2
    echo "[ERROR] unzip output:" >&2
    cat "$LOG_FILE" >&2 || true
    exit 1
fi

chmod +x "$TMP_DIR/hytale-downloader-linux-amd64"
exec "$TMP_DIR/hytale-downloader-linux-amd64" "$@"
EOF
RUN chmod +x /usr/local/bin/hytale-downloader

# Copy application files with correct ownership

USER apps
COPY --chmod=0755 . /
