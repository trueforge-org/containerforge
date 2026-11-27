#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
cd /config

# Optional ZIM download, only when the file is not already in /config.
# UNVERIFIED: curl must exist in the ubuntu base image.
if [ -n "${DOWNLOAD:-}" ]; then
    zim="/config/$(basename "${DOWNLOAD}")"
    if [ ! -s "${zim}" ]; then
        curl -fsSL -o "${zim}.part" "${DOWNLOAD}"
        mv "${zim}.part" "${zim}"
    fi
fi

shopt -s nullglob
zims=(/config/*.zim)
if [ "${#zims[@]}" -eq 0 ]; then
    # Open question: an empty /config should start cleanly. Decide before merge.
    echo "No .zim file in /config. Place one there or set DOWNLOAD, then restart." >&2
    exit 1
fi

# Foreground server, PID 1 via exec. UNVERIFIED: default bind address is all interfaces.
exec kiwix-serve --port="${PORT:-8080}" "${zims[@]}"
