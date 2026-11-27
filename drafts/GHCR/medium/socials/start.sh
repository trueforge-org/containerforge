#!/usr/bin/env bash
set -euo pipefail

# /app/socials/people is a symlink to /config/people. Seed the example profiles only for
# files that are missing, so existing user files are kept.
mkdir -p /config/people
cp -rn /defaults/people/. /config/people/

cd /app/socials
exec node dist/app.js
