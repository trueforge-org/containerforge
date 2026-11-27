#!/usr/bin/env bash
# UNVERIFIED: --data-dir and --output-dir flag names against the pinned web UI commit.
# UNVERIFIED: the web UI may write files (ui-config.json, config.json, logs) into its own root.
#   /app is read-only, so this must be checked on the first run before the image is called working.
# UNVERIFIED: model and extension paths are not redirected to /config yet.
set -eu

mkdir -p "${DATA_DIR}" /config/output /tmp/home /tmp/.cache

cd /app/stable-diffusion-webui

# CLI_ARGS is intentionally word-split into separate arguments.
# shellcheck disable=SC2086
exec /app/venv/bin/python -u webui.py \
    --listen \
    --port "${WEBUI_PORT}" \
    --skip-version-check \
    --data-dir "${DATA_DIR}" \
    --output-dir /config/output \
    ${CLI_ARGS:-}
