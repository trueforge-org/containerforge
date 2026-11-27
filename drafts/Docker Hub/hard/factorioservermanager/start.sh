#!/usr/bin/env bash
set -euo pipefail

CONFIG=/config
FACTORIO_DIR="${CONFIG}/factorio"
FSM_DATA="${CONFIG}/fsm-data"
PORT="${PORT:-8080}"

mkdir -p "${FSM_DATA}" "${FACTORIO_DIR}/saves" "${FACTORIO_DIR}/mods" "${FACTORIO_DIR}/config"

# Install Factorio headless once. The game is not in the image. Retried on the next start if this fails.
if [[ ! -x "${FACTORIO_DIR}/bin/x64/factorio" ]]; then
  version="${FACTORIO_VERSION:-stable}"
  if [[ ! "${version}" =~ ^[a-z0-9.]+$ ]]; then
    echo "invalid FACTORIO_VERSION" >&2
    exit 1
  fi
  echo "Downloading Factorio headless (${version})"
  curl -fL --retry 3 -o /tmp/factorio.tar.xz \
    "https://www.factorio.com/get-download/${version}/headless/linux64"
  tar -xJf /tmp/factorio.tar.xz -C "${CONFIG}"   # archive root is factorio/
  rm -f /tmp/factorio.tar.xz
fi

# conf.json: seed it only when missing so user changes survive restarts.
# UNVERIFIED: the upstream default leaves cookie_encryption_key empty. Whether FSM fills it in is not checked.
conf="${FSM_DATA}/conf.json"
if [[ ! -f "${conf}" ]]; then
  jq '.sq_lite_database_file="/config/fsm-data/sqlite.db" | .log_file="/config/fsm-data/factorio-server-manager.log"' \
    /app/fsm/conf.json > "${conf}.tmp"
  mv "${conf}.tmp" "${conf}"
fi

# Re-apply the RCON password on every start. It goes through the environment, not argv, so it stays out of the process list.
if [[ -n "${RCON_PASS:-}" ]]; then
  RCON_PASS="${RCON_PASS}" jq '.rcon_pass = env.RCON_PASS' "${conf}" > "${conf}.tmp"
  mv "${conf}.tmp" "${conf}"
fi

# Default login (ADMIN_USER/ADMIN_PASS on the Docker Hub page) is UNVERIFIED for this build. Change it in the UI.
# FSM listens on all interfaces by default (--host 0.0.0.0, per the upstream wiki, UNVERIFIED on this build).
cd /app/fsm
exec ./factorio-server-manager --conf "${conf}" --dir "${FACTORIO_DIR}" --port "${PORT}"
