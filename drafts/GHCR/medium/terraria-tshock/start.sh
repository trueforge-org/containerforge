#!/usr/bin/env bash
set -euo pipefail

WORLD_NAME="${TERRARIA_WORLD_NAME:-world}"
MAX_PLAYERS="${TERRARIA_MAX_PLAYERS:-8}"
WORLD_SIZE="${TERRARIA_WORLD_SIZE:-2}"

# All state goes under /config. /app/tshock is read-only at runtime.
mkdir -p /config/worlds /config/tshock
cd /config

WORLD="/config/worlds/${WORLD_NAME}.wld"
ARGS=(-port 7777 -maxplayers "${MAX_PLAYERS}" -worldpath /config/worlds)
if [ -f "${WORLD}" ]; then
  ARGS+=(-world "${WORLD}")
else
  # First start: create the world. UNVERIFIED: flag names and the size values for TShock 6.2.1.
  ARGS+=(-autocreate "${WORLD_SIZE}" -world "${WORLD}")
fi

# UNVERIFIED: the server entry (TShock.Server.dll or a launcher from the zip) and whether the Terraria server
# binary is included in the zip. The TShock admin setup is a manual in-game step (plan section 7).
exec dotnet /app/tshock/TShock.Server.dll "${ARGS[@]}"
