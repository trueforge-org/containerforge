#!/usr/bin/env bash

mkdir -p /config/user

# UNVERIFIED: seed a default config into /config only when missing (upstream copies default-config.json; check which file the server reads)

cd /app || exit 1
# UNVERIFIED: the server must listen on 0.0.0.0, not 127.0.0.1; check the listen call in the upstream source
exec node build/server.js
