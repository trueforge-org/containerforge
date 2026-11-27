#!/usr/bin/env bash

DATA_DIR="${DATA_DIR:-/config/mindustry}"
SRV_NAME="${SRV_NAME:-DockerMindustry}"
GAME_PARAMS="${GAME_PARAMS:-}"

# Only create the directory. Nothing is overwritten; the server writes its own config on first start.
mkdir -p "${DATA_DIR}"
cd "${DATA_DIR}" || exit 1

# Same argument shape as the ich777 wrapper: config name <name>,host,<extra>.
# UNVERIFIED: the semantics of these arguments on the server; confirm on the first run and record it here.
# The web console (gotty, screen, watchdog) is not ported.
# shellcheck disable=SC2086
exec java -jar /app/mindustry/server-release.jar \
  config name "${SRV_NAME}",host,${GAME_PARAMS}
