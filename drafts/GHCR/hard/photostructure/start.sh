#!/usr/bin/env bash
set -euo pipefail

# Persistent state lives in /config. Scratch lives in /tmp. Nothing writes to /opt/photostructure.
mkdir -p /config/library /config/system /config/pixi /tmp/photostructure

export PS_LIBRARY_DIR="${PS_LIBRARY_DIR:-/config/library}"
export PS_CONFIG_DIR="${PS_CONFIG_DIR:-/config/system}"
export PS_HTTP_PORT="${PS_HTTP_PORT:-1787}"

# UNVERIFIED: the start command. The upstream docker-entrypoint.sh was not read and the CLI flags are not confirmed.
# Check `photostructure --help` in the built image, and confirm that it binds 0.0.0.0 and the first-run FFmpeg prompt does not block startup.
cd /opt/photostructure
exec photostructure
