#!/usr/bin/env bash


mkdir -p /config/cache

# permissions
echo "Setting permissions"

exec /app/venv/bin/python /app/venv/bin/SickChill --datadir /config
