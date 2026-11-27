#!/bin/sh
# Initial draft port of lancachenet/monolithic startup (10_setup.sh / 15_generate_maps.sh are NOT yet ported).
# Idempotent. Runs as the unprivileged apps user. Config is rendered into /tmp, never /app.
set -eu

CACHE_INDEX_SIZE="${CACHE_INDEX_SIZE:-500m}"
CACHE_DISK_SIZE="${CACHE_DISK_SIZE:-1000g}"
CACHE_MAX_AGE="${CACHE_MAX_AGE:-3560d}"
NGINX_WORKER_PROCESSES="${NGINX_WORKER_PROCESSES:-auto}"

RUN_DIR=/tmp/nginx
TEMPLATE=/etc/nginx/lancache/nginx.conf.tmpl

mkdir -p "$RUN_DIR/client_body" "$RUN_DIR/proxy" "$RUN_DIR/fastcgi" "$RUN_DIR/uwsgi" "$RUN_DIR/scgi"
mkdir -p /data/cache /data/logs

if [ ! -w /data/cache ]; then
    echo "ERROR: /data/cache is not writable by $(id -un); mount a writable volume there." >&2
    exit 1
fi

# Escape a value for use as a sed replacement with '|' as delimiter.
esc() {
    printf '%s' "$1" | sed -e 's/[\\/&|]/\\&/g'
}

sed \
    -e "s|__NGINX_WORKER_PROCESSES__|$(esc "$NGINX_WORKER_PROCESSES")|g" \
    -e "s|__CACHE_INDEX_SIZE__|$(esc "$CACHE_INDEX_SIZE")|g" \
    -e "s|__CACHE_DISK_SIZE__|$(esc "$CACHE_DISK_SIZE")|g" \
    -e "s|__CACHE_MAX_AGE__|$(esc "$CACHE_MAX_AGE")|g" \
    "$TEMPLATE" > "$RUN_DIR/nginx.conf"

# Validate the rendered config before handing over to nginx.
nginx -t -c "$RUN_DIR/nginx.conf"

exec nginx -c "$RUN_DIR/nginx.conf" -g 'daemon off;'
