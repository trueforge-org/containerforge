#!/usr/bin/env bash

# data/ lives in /config through the symlink created at build time
mkdir -p /config/data

cd /app/flame || exit 1
exec node server.js
