#!/usr/bin/env bash
set -eu

CONFIG_DIR="${__SEARXNG_CONFIG_PATH:-/config}"
SETTINGS="${CONFIG_DIR}/settings.yml"
TEMPLATE="/app/searxng/settings.template.yml"

mkdir -p "${CONFIG_DIR}"

# Seed settings only when missing, and replace the public placeholder key once.
if [ ! -s "${SETTINGS}" ]; then
  cp "${TEMPLATE}" "${SETTINGS}"
  SECRET="$(head -c 24 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')"
  sed -i "s/ultrasecretkey/${SECRET}/" "${SETTINGS}"
fi

# SEARXNG_PORT must be numeric; anything else is ignored (matches upstream entrypoint).
case "${SEARXNG_PORT:-}" in
  '') ;;
  *[!0-9]*) unset SEARXNG_PORT ;;
  *) export GRANIAN_PORT="${SEARXNG_PORT}" ;;
esac

# UNVERIFIED: whether searx reads __SEARXNG_SETTINGS_PATH or SEARXNG_SETTINGS_PATH.
export SEARXNG_SETTINGS_PATH="${SETTINGS}"
export __SEARXNG_SETTINGS_PATH="${SETTINGS}"

cd /app/searxng
exec /app/venv/bin/granian searx.webapp:app
