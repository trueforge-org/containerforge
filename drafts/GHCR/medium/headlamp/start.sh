#!/usr/bin/env bash
set -eu

# Plugins live in /config so they persist; /app is never written.
mkdir -p /config/plugins

cd /app/headlamp
exec ./headlamp-server \
  -html-static-dir /app/headlamp/frontend \
  -plugins-dir /config/plugins
