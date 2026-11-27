#!/bin/sh
set -eu

# Persistent state lives in /config. /app stays read-only.
mkdir -p /config/mediafiles

export MEDIA_ROOT="${MEDIA_ROOT:-/config/mediafiles}"
export STATIC_ROOT="${STATIC_ROOT:-/tmp/staticfiles}"

# SECRET_KEY comes from the environment. If it is empty, generate it once into /config. The value is never printed.
if [ -z "${SECRET_KEY:-}" ]; then
  if [ ! -s /config/secret_key ]; then
    umask 077
    /app/venv/bin/python -c 'import secrets; print(secrets.token_urlsafe(50))' > /config/secret_key
  fi
  SECRET_KEY="$(cat /config/secret_key)"
  export SECRET_KEY
fi

cd /app
# UNVERIFIED: the migrate and collectstatic steps. Upstream boot.sh is not read yet, so confirm these run there.
# UNVERIFIED: the SQLite path. It must resolve to /config, because /app is read-only.
/app/venv/bin/python manage.py migrate --noinput
/app/venv/bin/python manage.py collectstatic --noinput

# UNVERIFIED: the WSGI module name (recipes.wsgi). Whitenoise serves STATIC_ROOT, so no nginx is needed for static files yet.
exec /app/venv/bin/gunicorn recipes.wsgi \
  --bind 0.0.0.0:8080 \
  --workers 3 \
  --threads 2 \
  --timeout 30
