#!/usr/bin/env bash
# UNVERIFIED: server/app.js was not read, so app-level config paths and env vars are unknown.
# Upstream runs nodemon (a dev tool) as the entrypoint. Plain node is used so the server is PID 1 and gets signals.
# UNVERIFIED: upstream installs git, so the server may clone or update Tasmota sources at runtime.
# If it does, that path must be under /tmp, because /app is read-only.
set -eu

mkdir -p /tmp/home /tmp/platformio

cd /app/tasmocompiler
exec node server/app.js
