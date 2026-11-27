#!/usr/bin/env bash

export MR_DOWNLOAD_DIR="${MR_DOWNLOAD_DIR:-/config/download}"
mkdir -p "${MR_DOWNLOAD_DIR}"

# The server reads templates and static files from /app, so run from there.
cd /app
exec /app/media-roller
