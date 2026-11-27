#!/usr/bin/env bash

# UNVERIFIED: confirm `--basedir` is a group option before `serve`, and that `--host`/`--port` are `serve` options (octoprint --help, octoprint serve --help).
mkdir -p /config/plugins
cd /config
exec /app/venv/bin/octoprint --basedir /config serve --host 0.0.0.0 --port 5000
