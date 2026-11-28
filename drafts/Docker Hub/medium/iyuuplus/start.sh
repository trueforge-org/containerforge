#!/usr/bin/env bash
set -euo pipefail

# /app/iyuuplus is read-only. The application writes into its own directory (.env, runtime/,
# config/crontab.php, ...), so a working copy lives in /config/iyuu, like upstream's /iyuu volume.
SRC="/app/iyuuplus"
DEST="/config/iyuu"
MARKER="${DEST}/.container-version"
WANT="${IYUU_VERSION:-unknown}"

mkdir -p "${DEST}"

if [ ! -f "${DEST}/start.php" ]; then
    # first start (empty /config)
    tar -C "${SRC}" -cf - . | tar -C "${DEST}" -xf -
    printf '%s' "${WANT}" > "${MARKER}"
elif [ "$(cat "${MARKER}" 2>/dev/null || true)" != "${WANT}" ]; then
    # image upgrade: replace code, keep user state
    tar -C "${SRC}" \
        --exclude=./.env \
        --exclude=./runtime \
        --exclude=./config/crontab.php \
        --exclude=./config/sites.php \
        --exclude=./plugin/admin/config/database.php \
        --exclude=./plugin/admin/config/thinkorm.php \
        -cf - . | tar -C "${DEST}" -xf -
    printf '%s' "${WANT}" > "${MARKER}"
fi

mkdir -p "${DEST}/runtime/logs"

# The push plugin hooks back into http://127.0.0.1:8787, so the port is not configurable.
export SERVER_LISTEN_PORT=8787

cd "${DEST}"
exec php start.php start
