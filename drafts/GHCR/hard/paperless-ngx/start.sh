#!/usr/bin/env bash
set -euo pipefail

# Persistent state under /config (paths are set in the Dockerfile). Create only what is missing.
mkdir -p /config/data /config/media /config/consume /config/export

# Secret key: use PAPERLESS_SECRET_KEY when set, otherwise generate one once and keep it in /config.
if [ -z "${PAPERLESS_SECRET_KEY:-}" ]; then
    secret_file="/config/data/secret_key"
    if [ ! -s "${secret_file}" ]; then
        head -c 48 /dev/urandom | base64 > "${secret_file}"
        chmod 600 "${secret_file}"
    fi
    PAPERLESS_SECRET_KEY="$(cat "${secret_file}")"
    export PAPERLESS_SECRET_KEY
fi

cd /app/src

# UNVERIFIED: migrations are run here because upstream runs them in its init scripts (not read).
python manage.py migrate --no-input

# Celery worker (tasks and consumption) in the background.
# UNVERIFIED: command and options, matching the upstream s6 celery service. The consumer is not run separately yet.
# PLAN DECISION OPEN: web + worker in one container, or split into two apps (plan section 10).
celery --app paperless worker --loglevel INFO &

# Web server runs in the foreground. exec so that signals reach it.
# UNVERIFIED: the granian command and the WSGI module path (plan section 7).
exec granian \
    --interface wsgi \
    --host 0.0.0.0 \
    --port "${PAPERLESS_PORT:-8000}" \
    paperless.wsgi:application
