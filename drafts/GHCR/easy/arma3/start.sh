#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

ARMA_DIR="/config/arma3"
mkdir -p "${ARMA_DIR}"

# Seed a minimal server.cfg only when missing. Never overwrite user state.
if [ ! -f "${ARMA_DIR}/server.cfg" ]; then
    cp /defaults/server.cfg "${ARMA_DIR}/server.cfg"
fi

# Install or update the server. Call steamcmd directly: /usr/local/bin/steamcmd
# runs /start.sh, which is this script, so it must not be used here.
# UNVERIFIED: the base's steamcmd runs without its /config/Steam bootstrap.
if [ "${VALIDATE:-false}" = "true" ]; then
    /usr/local/share/steamcmd/steamcmd.sh +force_install_dir "${ARMA_DIR}" +login anonymous +app_update 233780 validate +quit
else
    /usr/local/share/steamcmd/steamcmd.sh +force_install_dir "${ARMA_DIR}" +login anonymous +app_update 233780 +quit
fi

cd "${ARMA_DIR}"
# UNVERIFIED: server binary name (arma3server_x64 is a guess) and Linux launch arguments.
# The chart passes -config=server.cfg and an empty -mod=.
# UNVERIFIED: the server must bind all interfaces; test from outside the container.
exec ./arma3server_x64 -config=server.cfg -port=2302
