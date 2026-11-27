#!/usr/bin/env bash

# snippets.db and the generated JWT secret are written to /app/data/snippets,
# which is a symlink to /config/data/snippets (see the Dockerfile).
mkdir -p /config/data/snippets

cd /app/bytestash || exit 1
exec node src/app.js
