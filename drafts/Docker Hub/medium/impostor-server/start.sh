#!/usr/bin/env bash
set -eu

CONFIG_DIR=/config

mkdir -p "${CONFIG_DIR}" /tmp/dotnet-bundle

# Seed the default config only when missing. IMPOSTOR_* env vars still override values in the file.
if [ ! -f "${CONFIG_DIR}/config.json" ]; then
    cp /defaults/config.json "${CONFIG_DIR}/config.json"
fi

# Optional plugin and library dirs, only when the user has not set them.
# UNVERIFIED: array-key env binding (IMPOSTOR_PluginLoader__Paths__0); confirm with a dummy plugin.
mkdir -p "${CONFIG_DIR}/plugins" "${CONFIG_DIR}/libraries"
: "${IMPOSTOR_PluginLoader__Paths__0:=${CONFIG_DIR}/plugins}"
: "${IMPOSTOR_PluginLoader__LibraryPaths__0:=${CONFIG_DIR}/libraries}"
export IMPOSTOR_PluginLoader__Paths__0 IMPOSTOR_PluginLoader__LibraryPaths__0

# The server reads config.json from the working directory.
cd "${CONFIG_DIR}"
exec /app/Impostor.Server "$@"
