#!/usr/bin/env bash
set -euo pipefail

# Persistent state goes to /config. Database and media paths must be set through the pinry settings
# (variable names UNVERIFIED), so they point at /config.
mkdir -p /config/media /config/db

cd /app/pinry
/app/venv/bin/python manage.py migrate --noinput

# gunicorn is assumed to be in the requirements (UNVERIFIED). Upstream serves static files via nginx on port 80;
# a static-file solution is still open (plan section 10).
exec /app/venv/bin/gunicorn --bind 0.0.0.0:8000 pinry.wsgi:application
