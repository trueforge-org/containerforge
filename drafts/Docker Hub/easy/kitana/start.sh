#!/usr/bin/env bash
set -euo pipefail

RUN_DIR=/tmp/kitana

# Plex auth sessions are the only state worth keeping.
mkdir -p /config/sessions

# Kitana rewrites its compiled SASS under the working directory at every start and keeps
# its data under <script dir>/data. Run a fresh copy from /tmp so /app stays read-only.
rm -rf "${RUN_DIR}"
cp -a /app/kitana "${RUN_DIR}"
rm -rf "${RUN_DIR}/data"
mkdir -p "${RUN_DIR}/data"
ln -s /config/sessions "${RUN_DIR}/data/sessions"

cd "${RUN_DIR}"
# Extra upstream flags (for example -P, -p /kitana, -A <ENV_NAME>) are passed as container args.
exec /app/venv/bin/python kitana.py -B 0.0.0.0:31337 "$@"
