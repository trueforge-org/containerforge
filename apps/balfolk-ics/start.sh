#!/bin/sh

python3 /app/balfolk_ical.py && crond -f -L /dev/stdout & python3 -m http.server 8000 --directory /app
