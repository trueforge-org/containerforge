#!/usr/bin/env bash
set -euo pipefail

export GITEA_APP_INI="${GITEA_APP_INI:-/config/gitea/app.ini}"
export GITEA_WORK_DIR="${GITEA_WORK_DIR:-/config/gitea}"
export GITEA_CUSTOM="${GITEA_CUSTOM:-/config/gitea/custom}"
export GITEA_TEMP="${GITEA_TEMP:-/tmp/gitea}"

# Do not seed app.ini: the install wizard on first start writes it.
mkdir -p "${GITEA_CUSTOM}" "${GITEA_WORK_DIR}/data" "${GITEA_WORK_DIR}/log" "${GITEA_TEMP}"

exec /app/gitea/gitea -c "${GITEA_APP_INI}" web
