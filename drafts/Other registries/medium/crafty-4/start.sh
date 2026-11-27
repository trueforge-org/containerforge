#!/usr/bin/env bash
set -euo pipefail

CRAFTY_SRC=/app/crafty
CONFIG_DEFAULTS=/usr/local/share/crafty-4/config_original
CONFIG_DIR=/config/app/config
RUN_DIR=/tmp/crafty-4

mkdir -p "${CONFIG_DIR}" /config/servers /config/logs /config/import /config/backups

# Seed the panel config only when it is missing or empty. version.json is refreshed on every start.
if [[ -z "$(ls -A "${CONFIG_DIR}" 2>/dev/null)" ]]; then
    cp -a "${CONFIG_DEFAULTS}/." "${CONFIG_DIR}/"
fi
cp -f "${CONFIG_DEFAULTS}/version.json" "${CONFIG_DIR}/version.json"

# Build a writable run tree in /tmp. The code stays read-only in /app, and all state is symlinked into /config.
# UNVERIFIED: Crafty resolves its config, servers, logs, import and backups paths relative to its working directory.
rm -rf "${RUN_DIR}"
mkdir -p "${RUN_DIR}/app"
for entry in "${CRAFTY_SRC}"/*; do
    name="$(basename "${entry}")"
    if [[ "${name}" != "app" ]]; then
        ln -s "${entry}" "${RUN_DIR}/${name}"
    fi
done
for entry in "${CRAFTY_SRC}"/app/*; do
    ln -s "${entry}" "${RUN_DIR}/app/$(basename "${entry}")"
done
ln -s "${CONFIG_DIR}" "${RUN_DIR}/app/config"
for dir in servers logs import backups; do
    ln -s "/config/${dir}" "${RUN_DIR}/${dir}"
done

if [[ $# -eq 0 ]]; then
    set -- -d -i
fi

cd "${RUN_DIR}"
exec /app/venv/bin/python main.py "$@"
