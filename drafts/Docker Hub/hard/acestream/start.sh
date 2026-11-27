#!/bin/bash
set -euo pipefail

PORT="${PORT:-8080}"
SCHEME="${SCHEME:-http}"
ENTRY="${ENTRY:-}"

# Validate before rendering into nginx config, so env values cannot inject directives
[[ "${PORT}" =~ ^[0-9]+$ ]] || { echo "PORT must be numeric" >&2; exit 1; }
[[ "${SCHEME}" == "http" || "${SCHEME}" == "https" ]] || { echo "SCHEME must be http or https" >&2; exit 1; }
[[ -z "${ENTRY}" || "${ENTRY}" =~ ^[0-9]+$ ]] || { echo "ENTRY must be numeric or empty" >&2; exit 1; }
ENTRY_SUFFIX=""
[ -n "${ENTRY}" ] && ENTRY_SUFFIX=":${ENTRY}"

# Engine state lives in /tmp (read-only rootfs). UNVERIFIED: the engine honours HOME for .ACEStream.
export HOME=/tmp/ace TMPDIR=/tmp/ace/tmp TMP=/tmp/ace/tmp
mkdir -p /tmp/ace/.ACEStream /tmp/ace/tmp /tmp/nginx/conf.d /tmp/nginx/lib /tmp/nginx/logs

# Render the nginx server block from the template (upstream CMD does the same with sed)
sed -e "s|__PORT__|${PORT}|g" \
    -e "s|__SCHEME__|${SCHEME}|g" \
    -e "s|__ENTRY__|${ENTRY_SUFFIX}|g" \
    /etc/nginx/acestream.conf.template > /tmp/nginx/conf.d/default.conf

pids=()
trap 'kill -TERM "${pids[@]}" 2>/dev/null || true' TERM INT

# Search service (gunicorn) on localhost, behind nginx. UNVERIFIED: search.py must be vendored into /scripts.
gunicorn --bind 127.0.0.1:3031 --chdir /scripts search:app &
pids+=($!)

nginx -c /etc/nginx/nginx.conf -g 'daemon off;' &
pids+=($!)

# The engine must start from its own directory. It runs in the background, so the script keeps supervising.
cd /app/engine
./start-engine --client-console --live-cache-type memory &
pids+=($!)

# Three processes without a supervisor: exit as soon as one of them dies, so the container restarts
set +e
wait -n
status=$?
kill -TERM "${pids[@]}" 2>/dev/null || true
wait 2>/dev/null
exit "${status}"
