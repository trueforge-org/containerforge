#!/usr/bin/env bash
set -euo pipefail

# Targets of the symlinks created in the image (/app/posterr/{config,saved,public/custom}).
mkdir -p \
  /config/config \
  /config/custom/pictures/default \
  /tmp/saved/imagecache \
  /tmp/saved/mp3cache

# Seed the shipped custom.css only when missing; never overwrite user files.
if [[ ! -f /config/custom/custom.css && -f /app/posterr-custom.default/custom.css ]]; then
  cp /app/posterr-custom.default/custom.css /config/custom/custom.css
fi

cd /app/posterr
exec node index.js
