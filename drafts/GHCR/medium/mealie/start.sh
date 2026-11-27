#!/bin/sh
set -eu

# /app/data is a symlink to /config/data (created at build time). Create the target on every
# start. Existing data is never touched. Nothing is written under /app.
mkdir -p /config/data

cd /app
exec mealie
