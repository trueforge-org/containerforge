#!/usr/bin/env bash
set -e

CONFIG_FILE="${RECYCLARR_CONFIG_DIR:-/config}/recyclarr.yml"

# Create a default config only when asked and when none exists yet. Never overwrite.
if [ "${RECYCLARR_CREATE_CONFIG}" = "true" ] && [ ! -s "${CONFIG_FILE}" ]; then
  echo "Creating default config in ${RECYCLARR_CONFIG_DIR:-/config}"
  recyclarr config create
fi

# CLI passthrough, e.g. `docker run ... recyclarr sync`
if [ "$#" -gt 0 ]; then
  exec recyclarr "$@"
fi

# Scheduler: a plain bash loop, not supercronic (UNVERIFIED: supercronic not confirmed for ubuntu base).
# It supports the @hourly, @daily and @weekly macros and a plain number of seconds.
# Full cron expressions are NOT supported; unknown values fall back to @daily.
case "${CRON_SCHEDULE}" in
  @hourly) INTERVAL=3600 ;;
  @daily) INTERVAL=86400 ;;
  @weekly) INTERVAL=604800 ;;
  ''|*[!0-9]*) echo "Unsupported CRON_SCHEDULE '${CRON_SCHEDULE}', using @daily"; INTERVAL=86400 ;;
  *) INTERVAL="${CRON_SCHEDULE}" ;;
esac

echo "Starting recyclarr schedule every ${INTERVAL}s"

LOG_ARGS=()
if [ -n "${RECYCLARR_LOG_LEVEL}" ]; then
  LOG_ARGS=(--log "${RECYCLARR_LOG_LEVEL}") # UNVERIFIED: exact upstream flag syntax for log level
else
  LOG_ARGS=(--log)
fi

# Forward SIGTERM/SIGINT so the container stops cleanly (bash is PID 1 here).
trap 'echo "Stopping recyclarr scheduler"; exit 0' TERM INT

while true; do
  recyclarr sync "${LOG_ARGS[@]}" || echo "recyclarr sync failed, retrying at next interval"
  sleep "${INTERVAL}" &
  wait $!
done
