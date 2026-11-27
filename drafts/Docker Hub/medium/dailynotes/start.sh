#!/usr/bin/env bash

# Mirrors upstream run.sh (verify, migrate, verify migrations, gunicorn on 0.0.0.0:8000)
# but calls the bundled venv explicitly so PATH does not matter. Writes only to /config and /tmp.
mkdir -p /config
cd /app || exit 1

if [ -f /config/.env ]; then
  set -a
  # shellcheck disable=SC1091
  . /config/.env
  set +a
fi

/app/venv/bin/python verify_env.py || exit 1

if [ -f /config/.env ]; then
  set -a
  # shellcheck disable=SC1091
  . /config/.env
  set +a
fi

export FLASK_APP=server.py
/app/venv/bin/flask db upgrade || exit 1
/app/venv/bin/python verify_data_migrations.py || exit 1

exec /app/venv/bin/gunicorn server:app -b 0.0.0.0:8000
