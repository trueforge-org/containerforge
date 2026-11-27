#!/usr/bin/env bash

export SHOKO_HOME="${SHOKO_HOME:-/config/Shoko.CLI}"

mkdir -p "${SHOKO_HOME}"

if [[ -n "${UMASK}" ]]; then
    umask "${UMASK}"
fi

cd /app/shoko-server

# UNVERIFIED: the server must listen on 0.0.0.0:8111 (confirm the bind setting on first run).
exec ./Shoko.CLI
