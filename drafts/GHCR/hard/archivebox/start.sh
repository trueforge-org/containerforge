#!/usr/bin/env bash
set -euo pipefail

export DATA_DIR=/config/data
export XDG_CONFIG_HOME=/config/xdg/config

mkdir -p "${DATA_DIR}" "${XDG_CONFIG_HOME}"
cd "${DATA_DIR}"

# first start only: create the index and default config, keep existing data untouched
if [ ! -f "${DATA_DIR}/index.sqlite3" ]; then
    echo "New install detected, initialising ArchiveBox data in ${DATA_DIR}"
    # UNVERIFIED: --setup may prompt for an admin user; confirm it runs non-interactively
    archivebox init --setup
fi

# bind all interfaces so other containers can reach the web UI
exec archivebox server 0.0.0.0:5797
