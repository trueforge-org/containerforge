#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache
export PYTHONDONTWRITEBYTECODE=1
export CELERY_ALWAYS_EAGER="${CELERY_ALWAYS_EAGER:-true}"

CONFIG_DIR=/config
PASTE_INI="${CONFIG_DIR}/paste.ini"
MG_INI="${CONFIG_DIR}/mediagoblin.ini"
DEFAULTS=/app/mediagoblin-defaults
GMG=/app/venv/bin/gmg
PASTER=/app/venv/bin/paster
ADMIN_MARKER="${CONFIG_DIR}/.admin-created"

mkdir -p "${CONFIG_DIR}/user_dev/media/queue" \
    "${CONFIG_DIR}/user_dev/media/public" \
    "${CONFIG_DIR}/user_dev/plugin_static" \
    "${CONFIG_DIR}/user_dev/theme_static" \
    /tmp/.cache

# Seed the config only when it is missing. Existing user state is never overwritten.
if [ ! -f "${PASTE_INI}" ]; then
    cp "${DEFAULTS}/paste.ini" "${PASTE_INI}"
fi
if [ ! -f "${MG_INI}" ]; then
    cp "${DEFAULTS}/mediagoblin.ini" "${MG_INI}"
fi

# Rewrite the database engine on every start when SQL_ENGINE is set, so a changed value applies.
# Note: the URL can hold a DB password, so it ends up in mediagoblin.ini. Review before merge.
if [ -n "${SQL_ENGINE:-}" ]; then
    escaped_engine="$(printf '%s' "${SQL_ENGINE}" | sed -e 's/[\/&|]/\\&/g')"
    sed -i "s|^#\\?[[:space:]]*sql_engine[[:space:]]*=.*|sql_engine = ${escaped_engine}|" "${MG_INI}"
fi

cd "${CONFIG_DIR}"

# Idempotent on every start, as in the upstream entrypoint.
# UNVERIFIED: the -cf flag order for gmg.
"${GMG}" -cf "${MG_INI}" dbupdate
"${GMG}" -cf "${MG_INI}" assetlink

# First start only: create the admin account.
if [ ! -f "${ADMIN_MARKER}" ]; then
    ADMIN_USER="${ADMIN_USER:-admin}"
    ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"
    ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
    if [ -z "${ADMIN_PASSWORD}" ]; then
        ADMIN_PASSWORD="$(/app/venv/bin/python -c 'import secrets; print(secrets.token_hex(16))')"
        echo "Generated admin password for user ${ADMIN_USER}: ${ADMIN_PASSWORD}"
    fi
    # UNVERIFIED: --password puts the password in the process list. Check whether gmg adduser can read it from stdin.
    "${GMG}" -cf "${MG_INI}" adduser --username "${ADMIN_USER}" --password "${ADMIN_PASSWORD}" --email "${ADMIN_EMAIL}"
    "${GMG}" -cf "${MG_INI}" makeadmin "${ADMIN_USER}"
    touch "${ADMIN_MARKER}"
fi

exec "${PASTER}" serve "${PASTE_INI}" --server-name=broadcast
