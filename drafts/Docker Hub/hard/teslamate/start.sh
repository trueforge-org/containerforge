#!/usr/bin/env bash
set -euo pipefail

mkdir -p /tmp/srtm_cache /tmp/release /config

# ENCRYPTION_KEY encrypts stored Tesla tokens. Generate one into /config on first run only.
if [ -z "${ENCRYPTION_KEY:-}" ]; then
  if [ ! -s /config/encryption_key ]; then
    umask 077
    head -c 48 /dev/urandom | base64 | tr -d '\n' > /config/encryption_key
    echo "Generated ENCRYPTION_KEY in /config/encryption_key; keep it with your database backup" >&2
  fi
  ENCRYPTION_KEY="$(cat /config/encryption_key)"
  export ENCRYPTION_KEY
fi

# Mirrors upstream entrypoint.sh: lower the open-file limit to ULIMIT_MAX_NOFILE (UNVERIFIED semantic, check when implementing)
ulimit -n "${ULIMIT_MAX_NOFILE:-65536}" 2>/dev/null || true

cd /app/teslamate
/app/teslamate/bin/teslamate eval "TeslaMate.Release.wait_for_database_and_migrate()"
exec /usr/bin/tini -- /app/teslamate/bin/teslamate start
