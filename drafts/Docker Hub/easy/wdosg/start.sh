#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-3001}"
export GAMES_LIBRARY="${GAMES_LIBRARY:-/config/wdosglibrary}"
export DB_PATH="${DB_PATH:-/config/database}"
export LOG_LEVEL="${LOG_LEVEL:-info}"
mkdir -p "${GAMES_LIBRARY}" "${DB_PATH}" /tmp/tmp

# v1.3.9 exits when the IGDB credentials are empty. DISABLED turns IGDB off (per the README).
if [[ -z "${TWITCH_CLIENT_ID:-}" && -z "${TWITCH_CLIENT_ID_FILE:-}" ]]; then
    export TWITCH_CLIENT_ID=DISABLED
fi
if [[ -z "${TWITCH_CLIENT_SECRET:-}" && -z "${TWITCH_CLIENT_SECRET_FILE:-}" ]]; then
    export TWITCH_CLIENT_SECRET=DISABLED
fi

# Stable session secret: generated once into /config (mode 0600) and never overwritten.
# Upstream's fallback "secret" is weak, so it is not used.
if [[ -z "${TOKEN_SECRET:-}" && -z "${TOKEN_SECRET_FILE:-}" ]]; then
    if [[ ! -s /config/.token_secret ]]; then
        ( umask 077; head -c 48 /dev/urandom | base64 | tr -d '\n=/+' > /config/.token_secret )
    fi
    TOKEN_SECRET="$(< /config/.token_secret)"
    export TOKEN_SECRET
fi

# The app writes ./tmp/ relative to its cwd, so start from /tmp (ephemeral)
cd /tmp
exec node /app/wdosg/index.js
