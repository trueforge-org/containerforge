#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${SOURCE_DIR:-/data}"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-3600}"
RUN_ONCE="${RUN_ONCE:-false}"

# Credentials come from the environment only. They are never written to a file or passed on the command line.
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-${ACCESS_KEY:-}}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-${SECRET_KEY:-}}"
if [ -n "${REGION:-}" ]; then
  export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-${REGION}}"
fi
# An empty key pair is removed so the CLI falls back to its normal credential chain.
if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
fi

if [ -z "${S3PATH:-}" ]; then
  echo "S3PATH is not set; nothing to sync. Idling." >&2
  exec sleep infinity
fi

# Split on whitespace, as the upstream wrapper did (for example "--endpoint-url http://minio:9000").
read -r -a sync_params <<< "${S3SYNCPARAMS:-}" || true

sync_once() {
  /app/venv/bin/aws s3 sync "${SOURCE_DIR%/}/" "${S3PATH}" ${sync_params[@]+"${sync_params[@]}"}
}

# A CronJob can set RUN_ONCE=true. A failed sync then exits non-zero.
if [ "${RUN_ONCE}" = "true" ]; then
  sync_once
  exit 0
fi

# Sequential loop, so there is no lock file to go stale. SIGTERM ends the wait.
trap 'exit 0' TERM INT
while true; do
  sync_once || echo "sync failed, retrying in ${INTERVAL_SECONDS}s" >&2
  sleep "${INTERVAL_SECONDS}" &
  wait $!
done
