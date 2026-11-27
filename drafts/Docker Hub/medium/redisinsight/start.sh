#!/usr/bin/env bash
set -eu

# The app keeps its database, plugins and logs under RI_APP_FOLDER_ABSOLUTE_PATH (/config).
mkdir -p "${RI_APP_FOLDER_ABSOLUTE_PATH:-/config}"

# UNVERIFIED: the listen host. Check that the server binds 0.0.0.0 and not localhost.
cd /app/redisinsight
exec node redisinsight/api/dist/src/main
