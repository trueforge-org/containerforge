#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config /tmp/songkong
export HOME=/config

cd /app

# UNVERIFIED: songkongremote.sh should end in an exec of java so signals reach the app.
# If it does not, copy its java command here and exec that instead.
exec ./songkongremote.sh
