#!/bin/sh
set -eu

# Persistent data and uploads live on /config. /app/backend/data and /app/frontend/public/img are symlinks to it.
mkdir -p /config/data /config/img

# Seed the default images only when missing, so uploads and a changed logo are never overwritten.
cp -rn /usr/share/pingvin-share/img-defaults/. /config/img/ 2>/dev/null || true

# Caddy state goes to /tmp, not to $HOME.
export XDG_DATA_HOME=/tmp/caddy-data
export XDG_CONFIG_HOME=/tmp/caddy-config
mkdir -p "${XDG_DATA_HOME}" "${XDG_CONFIG_HOME}"

# Caddy listens on 3000 (EXPOSE). UNVERIFIED: the Caddyfile content was not fetched; check the port it serves.
if [ "${CADDY_DISABLED:-false}" != "true" ]; then
    if [ "${TRUST_PROXY:-false}" = "true" ]; then
        caddy start --adapter caddyfile --config /app/reverse-proxy/Caddyfile.trust-proxy
    else
        caddy start --adapter caddyfile --config /app/reverse-proxy/Caddyfile
    fi
fi

# Frontend (Next.js standalone) in the background, as upstream does.
# UNVERIFIED: upstream waits with `wait -n`. Here only the backend is exec'd, so a frontend crash is not seen.
(
    cd /app/frontend
    PORT=3333 HOSTNAME=0.0.0.0 exec node server.js
) &

# Backend in the foreground. exec so signals reach the process.
cd /app/backend
exec npm run prod
