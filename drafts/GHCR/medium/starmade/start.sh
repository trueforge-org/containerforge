#!/usr/bin/env bash
set -euo pipefail

# Starter jar is baked into the image at build time (read-only /app).
STARTER_JAR=/app/starmade/StarMade-Starter.jar
GAME_DIR=/config/StarMade

XMX_SIZE="${XMX_SIZE:-1024}"
XMS_SIZE="${XMS_SIZE:-1024}"
EXTRA_JVM_PARAMS="${EXTRA_JVM_PARAMS:-}"
GAME_PARAMS="${GAME_PARAMS:-}"

mkdir -p /config/runtime "${GAME_DIR}"

# Seed server.cfg only when missing. UNVERIFIED: no defaults/server.cfg is shipped yet.
if [[ ! -f "${GAME_DIR}/server.cfg" && -f /defaults/server.cfg ]]; then
    cp /defaults/server.cfg "${GAME_DIR}/server.cfg"
fi

# Run the Starter from /config so it installs or updates the game in /config/StarMade.
# UNVERIFIED: the Starter writes into the current directory and exits; check on a first run.
cd /config
java -jar "${STARTER_JAR}" -nogui

# Split the JVM and game parameters into arrays, so values with spaces stay intact.
IFS=' ' read -r -a jvm_opts <<< "${EXTRA_JVM_PARAMS}" || true
IFS=' ' read -r -a game_opts <<< "${GAME_PARAMS}" || true

cd "${GAME_DIR}"
exec java \
    "${jvm_opts[@]}" \
    "-Xmx${XMX_SIZE}M" \
    "-Xms${XMS_SIZE}M" \
    -jar StarMade.jar \
    -server \
    "${game_opts[@]}"
