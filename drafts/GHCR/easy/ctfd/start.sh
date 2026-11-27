#!/usr/bin/env bash
set -euo pipefail

# Run from /config so that no runtime write lands in /app, which is read-only.
# UNVERIFIED: whether the default SQLite database and filesystem cache go under the working directory (.data). Confirm in config.py.
cd /config

export PATH="/app/venv/bin:${PATH}"
export PYTHONPATH=/app/CTFd
export TMPDIR=/tmp
# UNVERIFIED: flask needs the app factory set explicitly because the working directory is /config.
export FLASK_APP="CTFd:create_app"

WORKERS="${WORKERS:-1}"
WORKER_CLASS="${WORKER_CLASS:-gevent}"
ACCESS_LOG="${ACCESS_LOG:--}"
ERROR_LOG="${ERROR_LOG:--}"
WORKER_TEMP_DIR="${WORKER_TEMP_DIR:-/tmp}"
SKIP_DB_PING="${SKIP_DB_PING:-false}"

mkdir -p /config/uploads /config/logs
export UPLOAD_FOLDER="${UPLOAD_FOLDER:-/config/uploads}"
export LOG_FOLDER="${LOG_FOLDER:-/config/logs}"

# Use SECRET_KEY when it is set. Otherwise use a key stored in /config and generated once.
if [ -z "${SECRET_KEY:-}" ]; then
    if [ ! -s /config/.secret_key ]; then
        (umask 077 && python -c 'import secrets; print(secrets.token_hex(32))' > /config/.secret_key)
    fi
    SECRET_KEY="$(cat /config/.secret_key)"
fi
export SECRET_KEY

# Same rule as upstream: ping the database unless SKIP_DB_PING is set to a value other than false or empty.
if [ "${SKIP_DB_PING}" = "false" ] || [ -z "${SKIP_DB_PING}" ]; then
    python /app/CTFd/ping.py
fi

flask db upgrade

echo "Starting CTFd"
exec gunicorn 'CTFd:create_app()' \
    --bind 0.0.0.0:8000 \
    --workers "${WORKERS}" \
    --worker-tmp-dir "${WORKER_TEMP_DIR}" \
    --worker-class "${WORKER_CLASS}" \
    --access-logfile "${ACCESS_LOG}" \
    --error-logfile "${ERROR_LOG}"
