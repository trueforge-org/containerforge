#!/usr/bin/env bash

# UMS reads its profile from UMS_PROFILE (set in the Dockerfile to /config/profile).
profile="${UMS_PROFILE:-/config/profile}"
mkdir -p "${profile}"

# run from /config so relative writes (logs, caches) stay off /app
cd /config || exit 1

# UNVERIFIED: jar path depends on the release tarball layout
exec java -jar /app/ums/ums.jar "$@"
