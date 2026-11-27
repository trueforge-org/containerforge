#!/usr/bin/env bash
# Initial draft. OPEN (plan sections 7 and 10): the web layer, port (4848 vs 8080), DJANGO_SECRET_KEY generation,
# and TUBESYNC_RESET_DOWNLOAD_DIR, which upstream uses to chown /downloads and cannot do as the apps user.
# UNVERIFIED: the WSGI module path and the gunicorn install.

mkdir -p /config/tubesync /config/state /tmp/cache
cd /app/tubesync || exit 1

# Migrations run on every start. The SQLite database lives in /config.
/app/venv/bin/python manage.py migrate --noinput

exec /app/venv/bin/gunicorn tubesync.wsgi:application --bind "0.0.0.0:${LISTEN_PORT:-4848}"
