#!/bin/bash
set -e

cd /app/shlink

# persistent state lives in /config/data (symlinked as /app/shlink/data)
mkdir -p /config/data/cache /config/data/locks /config/data/log /config/data/proxies /config/data/temp-geolite

flags="--no-interaction --clear-db-cache"

if [ -z "${GEOLITE_LICENSE_KEY:-}" ] || [ "${SKIP_INITIAL_GEOLITE_DOWNLOAD:-false}" = "true" ]; then
  flags="${flags} --skip-download-geolite"
fi

if [ -n "${INITIAL_API_KEY:-}" ]; then
  flags="${flags} --initial-api-key=${INITIAL_API_KEY}"
fi

# shellcheck disable=SC2086
php vendor/bin/shlink-installer init ${flags}

if [ "${SHLINK_RUNTIME:-rr}" = "rr" ]; then
  exec ./bin/rr serve -c config/roadrunner/.rr.yml
fi

echo "SHLINK_RUNTIME=${SHLINK_RUNTIME} is not supported by this image" >&2
exit 1
