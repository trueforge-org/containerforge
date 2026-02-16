#!/usr/bin/env bash
cd /app/apprise_api
exec /app/venv/bin/uwsgi --http-socket=:8000 --enable-threads --virtualenv=/app/venv --module=core.wsgi:application --static-map=/s=static --buffer-size=32768
