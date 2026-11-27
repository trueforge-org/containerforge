#!/usr/bin/env bash

mkdir -p /config

# UNVERIFIED: seed the server's default config into /config with `cp -n` once the file names are known.
# UNVERIFIED: link or copy the server's writable folders into /config here once they are confirmed.
# UNVERIFIED: the bind address. Check that the server listens on 0.0.0.0, not localhost.

cd /app/lmp || exit 1
# UNVERIFIED: the entry DLL name. Confirm it from the zip layout.
exec /usr/bin/dotnet LunaMultiplayerServer.dll
