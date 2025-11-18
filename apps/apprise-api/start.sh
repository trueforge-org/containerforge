#!/usr/bin/env bash
cd /app/apprise_api
exec /usr/sbin/uwsgi --http-socket=:8000 --enable-threads --plugin=python3 --module=core.wsgi:application --static-map=/s=static --buffer-size=32768 -H /config/venv
