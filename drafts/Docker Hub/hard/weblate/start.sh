#!/bin/bash
set -euo pipefail

# UNVERIFIED: this is a simplified draft. The upstream `start` script (plan section 7) and the vendored etc/ files were not fetched.
# Here nginx, granian and celery are run as children of this script, without supervisor.
# Remaining plan items: admin creation, the upstream dependency checks, and the vendored upstream config.

export DJANGO_SETTINGS_MODULE=weblate.settings_docker
export WEBLATE_DATA_DIR="${WEBLATE_DATA_DIR:-/config/data}"
export WEBLATE_CACHE_DIR="${WEBLATE_CACHE_DIR:-/tmp/cache}"
export POSTGRES_HOST="${POSTGRES_HOST:-postgresql}"
export POSTGRES_PORT="${POSTGRES_PORT:-5432}"
export REDIS_HOST="${REDIS_HOST:-valkey}"
export REDIS_PORT="${REDIS_PORT:-6379}"
export TZ="${TZ:-Etc/UTC}"

mkdir -p "$WEBLATE_DATA_DIR"/media "$WEBLATE_DATA_DIR"/fonts "$WEBLATE_DATA_DIR"/ssl \
  "$WEBLATE_DATA_DIR"/python/customize "$WEBLATE_CACHE_DIR" /tmp/run/granian /tmp/nginx

# Seed the customize module only when the files are missing.
for f in __init__.py models.py; do
  if [[ ! -f "$WEBLATE_DATA_DIR/python/customize/$f" ]]; then
    : > "$WEBLATE_DATA_DIR/python/customize/$f"
  fi
done

# The secret key is generated once and kept in the data dir. It is never printed.
if [[ -z "${WEBLATE_SECRET_KEY:-}" ]]; then
  secret_file="$WEBLATE_DATA_DIR/secret"
  if [[ ! -s "$secret_file" ]]; then
    umask 077
    /app/venv/bin/python -c 'import secrets; print(secrets.token_urlsafe(50))' > "$secret_file"
  fi
  WEBLATE_SECRET_KEY="$(cat "$secret_file")"
  export WEBLATE_SECRET_KEY
fi

pids=()

cleanup() {
  if ((${#pids[@]} > 0)); then
    kill "${pids[@]}" 2>/dev/null || true
    wait 2>/dev/null || true
  fi
}
trap 'cleanup; exit 0' TERM INT

# nginx starts first, so the startup page is served while the dependencies are not up yet.
nginx -c /etc/weblate/nginx/nginx.conf -g 'daemon off;' &
pids+=("$!")

wait_for() {
  local host="$1" port="$2" name="$3"
  until (exec 3<>"/dev/tcp/$host/$port") 2>/dev/null; do
    echo "waiting for $name at $host:$port"
    sleep 5
  done
}
wait_for "$POSTGRES_HOST" "$POSTGRES_PORT" "PostgreSQL"
wait_for "$REDIS_HOST" "$REDIS_PORT" "Valkey"

# UNVERIFIED: migrations and collectstatic run on every start, as the plan describes for upstream.
/app/venv/bin/weblate migrate --noinput
/app/venv/bin/weblate collectstatic --noinput

# UNVERIFIED: granian flags. The socket path replaces the upstream /run/granian path.
/app/venv/bin/granian --interface wsgi --uds /tmp/run/granian/granian.sock weblate.wsgi:application &
pids+=("$!")

# UNVERIFIED: celery flags. The beat schedule is kept in /tmp, because /config is for persistent state only.
/app/venv/bin/celery --app weblate.utils.celery worker --beat --concurrency 2 \
  --schedule /tmp/run/celerybeat-schedule --loglevel INFO &
pids+=("$!")

# Exit as soon as any child exits, so a failed process stops the container.
status=0
wait -n "${pids[@]}" || status=$?
cleanup
exit "$status"
