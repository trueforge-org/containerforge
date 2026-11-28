#!/usr/bin/env bash
set -euo pipefail

# UNVERIFIED: the key generation and JWT key commands. Upstream uses `adonis key:generate --force`, which writes /app/.env.
# /app is read-only here, so this draft uses `node ace generate:key --show` and keeps the output in /config.

export NODE_ENV="${NODE_ENV:-production}"
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-3333}"
export DATA_DIR="${DATA_DIR:-/config/data}"

cd /app/ferdi-server

mkdir -p "$DATA_DIR" /config/recipes

# Seed the recipes only when the directory is empty, so custom recipes are kept.
if [[ -z "$(ls -A /config/recipes 2>/dev/null)" ]]; then
  cp -a /app/recipes-seed/. /config/recipes/
fi

# The app key is generated once and read back from /config. It is never printed to the log.
key_file="$DATA_DIR/FERDIUM_APP_KEY.txt"
if [[ -z "${APP_KEY:-}" ]]; then
  if [[ ! -s "$key_file" ]]; then
    umask 077
    node ace generate:key --show > "$key_file.tmp"
    mv "$key_file.tmp" "$key_file"
  fi
  APP_KEY="$(cat "$key_file")"
fi
export APP_KEY

# JWT keys, only when JWT_USE_PEM is "true". Generated once, then reused.
if [[ "${JWT_USE_PEM:-}" == "true" ]]; then
  pub="$DATA_DIR/FERDIUM_JWT_PUBLIC_KEY.pem"
  priv="$DATA_DIR/FERDIUM_JWT_PRIVATE_KEY.pem"
  if [[ ! -s "$pub" || ! -s "$priv" ]]; then
    umask 077
    node ace jwt:generate-keys "$DATA_DIR"
    mv "$DATA_DIR/public.pem" "$pub"
    mv "$DATA_DIR/private.pem" "$priv"
  fi
  JWT_PUBLIC_KEY="$(cat "$pub")"
  JWT_PRIVATE_KEY="$(cat "$priv")"
  export JWT_PUBLIC_KEY JWT_PRIVATE_KEY
fi

# Migrations run on every start. Migrations that were already applied are skipped.
# The v4 to v5 script in the upstream entrypoint is not ported, because this image is for fresh installs.
node ace migration:run --force

exec node build/server.js
