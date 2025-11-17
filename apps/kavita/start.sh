#!/usr/bin/env bash

echo "defaults content:"
ls -l /defaults
echo "app content:"
ls -l /app
echo "config content:"
ls -l /config

cp -rn /defaults /config/config

exec /app/Kavita $@

