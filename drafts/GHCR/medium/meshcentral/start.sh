#!/bin/bash
set -eu

DATA=/config/meshcentral-data
PORT="${PORT:-8443}"
REDIR_PORT="${REDIR_PORT:-8080}"

mkdir -p "${DATA}" /config/meshcentral-files /config/meshcentral-web /config/meshcentral-backups

# Seed config.json only when missing or empty. Never overwrite user state.
# The template's placeholder session key is dropped, and new account creation is off by default.
if [ ! -s "${DATA}/config.json" ]; then
  jq 'del(.settings._sessionKey) | .domains[""].NewAccounts = false' \
    /defaults/config.json.template > "${DATA}/config.json.tmp"
  mv "${DATA}/config.json.tmp" "${DATA}/config.json"
fi

# Apply the ports from env on every start.
# UNVERIFIED: the enrollment hostname is left to the user in settings.cert (template placeholder).
# Docker sets HOSTNAME to the container ID, so it is not used here.
jq --argjson port "${PORT}" --argjson redir "${REDIR_PORT}" \
  '.settings.port = $port | .settings.redirPort = $redir' \
  "${DATA}/config.json" > "${DATA}/config.json.tmp"
mv "${DATA}/config.json.tmp" "${DATA}/config.json"

cd /app/meshcentral
exec node node_modules/meshcentral/meshcentral.js
