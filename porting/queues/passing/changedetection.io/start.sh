#!/usr/bin/env bash


cd /app/changedetection
exec /app/venv/bin/python /app/changedetection/changedetection.py -d /config
