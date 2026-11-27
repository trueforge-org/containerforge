#!/usr/bin/env bash

mkdir -p "${WATCHARR_DATA:-/config/data}"

# The server reads ./ui relative to its working directory, so start from /app/watcharr.
cd /app/watcharr || exit 1
exec /app/watcharr/watcharr
