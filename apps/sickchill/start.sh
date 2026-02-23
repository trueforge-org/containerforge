#!/usr/bin/env bash


mkdir -p /config/cache

exec /app/venv/bin/python /app/venv/bin/SickChill --datadir /config
