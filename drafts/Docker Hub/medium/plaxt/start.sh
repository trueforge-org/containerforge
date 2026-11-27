#!/usr/bin/env bash

# UNVERIFIED: keystore path. Upstream VOLUME is /app/keystore/; check whether the binary
# hard-codes it. If it does, add a build-time symlink /app/plaxt/keystore -> /config/keystore.
mkdir -p /config/keystore

cd /app/plaxt
exec /app/plaxt/plaxt
