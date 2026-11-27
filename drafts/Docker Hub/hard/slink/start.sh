#!/bin/bash
set -euo pipefail

# UNVERIFIED: process list and startup order are from the plan. Upstream s6 service scripts were not read.
# Four processes run in one container: valkey, php-fpm, caddy (mercure hub) and the node client.

# Persistent state lives in /config. Caches and runtime scratch live in /tmp.
for dir in /config/data/keys /config/images /config/redis /config/caddy; do
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    if [[ "$dir" == "/config/data/keys" ]]; then
      chmod 750 "$dir"
    fi
  fi
done
mkdir -p /tmp/slink/cache /tmp/slink/log /tmp/slink/php /tmp/slink/caddy

# Defaults match settings.yaml. Exported so php-fpm (clear_env = no) and node see them.
export TZ="${TZ:-Etc/UTC}"
export ORIGIN="${ORIGIN:-http://localhost:3000}"
export USER_APPROVAL_REQUIRED="${USER_APPROVAL_REQUIRED:-true}"
export USER_ALLOW_REGISTRATION="${USER_ALLOW_REGISTRATION:-true}"
export IMAGE_MAX_SIZE="${IMAGE_MAX_SIZE:-15M}"
export STORAGE_PROVIDER="${STORAGE_PROVIDER:-local}"
export ADMIN_EMAIL="${ADMIN_EMAIL:-}"
export ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
export ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"

pids=()

cleanup() {
  if ((${#pids[@]} > 0)); then
    kill "${pids[@]}" 2>/dev/null || true
    wait 2>/dev/null || true
  fi
}
trap 'cleanup; exit 0' TERM INT

# Valkey is internal only. It listens on loopback and keeps its data in /config/redis.
valkey-server --bind 127.0.0.1 --port 6379 --dir /config/redis --appendonly yes &
pids+=("$!")

# PHP-FPM pool config writes only to /tmp (see defaults/php-fpm.conf).
php-fpm8.5 -F -y /defaults/php-fpm.conf &
pids+=("$!")

# UNVERIFIED: the schema migration command. The upstream `slink` wrapper was not read.
php /app/api/bin/console doctrine:migrations:migrate --no-interaction

# Caddy serves the API and the mercure hub on loopback port 8080.
/app/caddy run --config /defaults/Caddyfile --adapter caddyfile &
pids+=("$!")

# The node client listens on all interfaces.
(
  cd /app/client
  HOST=0.0.0.0 PORT=3000 exec node server.js
) &
pids+=("$!")

# Exit as soon as any child exits, so a failed helper stops the container.
status=0
wait -n "${pids[@]}" || status=$?
cleanup
exit "$status"
