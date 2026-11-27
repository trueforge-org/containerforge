#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${SOURCE_DIR:-/data}"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-3600}"
S3CMD=/app/venv/bin/s3cmd
CFG=/tmp/s3cfg

umask 077

if [ -z "${S3PATH:-}" ]; then
  echo "S3PATH is not set; nothing to back up. Idling." >&2
  exec sleep infinity
fi

# The config has no credentials. UNVERIFIED: s3cmd falls back to AWS_* environment
# variables when access_key is empty, so no secret is written to disk or argv.
printf '[default]\n' > "${CFG}"
if [ -n "${ACCESS_KEY:-}" ]; then
  export AWS_ACCESS_KEY_ID="${ACCESS_KEY}"
  export AWS_SECRET_ACCESS_KEY="${SECRET_KEY:-}"
fi

# S3CMDPARAMS is split on whitespace on purpose, e.g. "--host=minio:9000 --no-ssl".
read -r -a params <<< "${S3CMDPARAMS:-}"

if [ "${RUN_ONCE:-false}" = "true" ]; then
  exec "${S3CMD}" --config="${CFG}" sync "${SOURCE_DIR%/}/" "${S3PATH}" "${params[@]}"
fi

run_sync() {
  "${S3CMD}" --config="${CFG}" sync "${SOURCE_DIR%/}/" "${S3PATH}" "${params[@]}"
}

trap 'exit 0' TERM INT
while true; do
  run_sync || echo "sync failed, retrying in ${INTERVAL_SECONDS}s" >&2
  sleep "${INTERVAL_SECONDS}" &
  wait $!
done
