#!/usr/bin/env bash

mkdir -p /config "${ETV_TRANSCODE_FOLDER:-/tmp/transcode}"

# UNVERIFIED: whether ErsatzTV binds to 0.0.0.0 by default. Check the listen address on first run.
cd /app || exit 1
exec ./ErsatzTV
