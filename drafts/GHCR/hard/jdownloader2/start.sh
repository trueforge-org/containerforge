#!/usr/bin/env bash
set -euo pipefail

export HOME=/config

mkdir -p /config/jdownloader /config/output

# Copy the JAR to /config on first start so the app can write its files there.
# /app stays read-only. The copy is not refreshed when the image is updated.
if [ ! -f /config/jdownloader/JDownloader.jar ]; then
    cp /app/jdownloader/JDownloader.jar /config/jdownloader/JDownloader.jar
fi

heap_args=()
if [ -n "${JDOWNLOADER_MAX_MEM:-}" ]; then
    heap_args=("-Xmx${JDOWNLOADER_MAX_MEM}")
fi

cd /config/jdownloader
# UNVERIFIED: headless mode and the self-update behaviour must be checked on a real run.
exec java "${heap_args[@]}" \
    -Djava.io.tmpdir=/tmp \
    -Djava.awt.headless=true \
    -jar /config/jdownloader/JDownloader.jar
