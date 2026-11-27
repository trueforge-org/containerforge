#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

USERDATA=/config
mkdir -p "${USERDATA}"

# Seed bundled content into the writable userdata only when missing. Never overwrite user edits.
seed() { # $1 source under /app, $2 destination under userdata
  if [ ! -e "$2" ]; then
    mkdir -p "$(dirname "$2")"
    cp -r "$1" "$2"
  fi
}
seed /app/plugins/examples          "${USERDATA}/plugins/examples"
seed /app/www/templates             "${USERDATA}/www/templates"
seed /app/scripts/dzVents/examples  "${USERDATA}/scripts/dzVents/examples"

# Bundled plugins other than examples. Copy only the missing ones.
# UNVERIFIED: bundled plugin updates in newer images are not applied to existing /config copies.
for plugin in /app/plugins/*/; do
  name="$(basename "${plugin}")"
  if [ "${name}" != "examples" ]; then
    seed "${plugin%/}" "${USERDATA}/plugins/${name}"
  fi
done

ARGS=(-www "${WWW_PORT:-8080}" -sslwww "${SSL_PORT:-0}" -noupdates \
  -userdata "${USERDATA}/" -dbase "${DATABASE_PATH:-/config/domoticz.db}")
if [ -n "${LOG_PATH:-}" ]; then
  ARGS+=(-log "${LOG_PATH}")
fi

cd /app
# EXTRA_CMD_ARG is split on whitespace on purpose (flags). It is never evaluated by a shell.
# shellcheck disable=SC2206
exec /app/domoticz "${ARGS[@]}" ${EXTRA_CMD_ARG:-}
