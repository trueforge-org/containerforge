#!/usr/bin/env bash

mkdir -p /config/user_data

cd /app/dashmachine || exit 1

exec /app/venv/bin/gunicorn --bind 0.0.0.0:5000 wsgi:app
