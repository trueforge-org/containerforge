#!/usr/bin/env bash
set -euo pipefail

PROJECTS_DIR=/config/projects
DATA_DIR=/config/data
CONFIG_FILE="${PROJECTS_DIR}/config.json"

mkdir -p "${PROJECTS_DIR}" "${DATA_DIR}"
ulimit -c 0

# Seed config.json from the environment only when it is missing or is not valid JSON, as upstream start.py does.
# UNVERIFIED: upstream start.py writes this file relative to /home/warrior; the path here is /config/projects.
if ! python3 -I -c 'import json, sys; json.load(open(sys.argv[1]))' "${CONFIG_FILE}" 2>/dev/null; then
    python3 -I - "${CONFIG_FILE}" <<'PY'
import json
import os
import sys

config = {
    'downloader': os.getenv('DOWNLOADER', ''),
    'http_username': os.getenv('HTTP_USERNAME', ''),
    'http_password': os.getenv('HTTP_PASSWORD', ''),
    'selected_project': os.getenv('SELECTED_PROJECT', ''),
    'shared:rsync_threads': os.getenv('SHARED_RSYNC_THREADS', ''),
    'warrior_id': os.getenv('WARRIOR_ID', ''),
    'concurrent_items': os.getenv('CONCURRENT_ITEMS', ''),
}
with open(sys.argv[1], 'w') as fp:
    json.dump(config, fp)
PY
fi

# UNVERIFIED: the bind address of run-warrior3 (expected to listen on all interfaces on 8001).
exec run-warrior3 \
    --projects-dir "${PROJECTS_DIR}" \
    --data-dir "${DATA_DIR}" \
    --warrior-hq https://warriorhq.archiveteam.org \
    --port 8001 \
    --real-shutdown
