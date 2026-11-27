#!/usr/bin/env bash
# shellcheck shell=bash

umask "${UMASK:-002}"

# Persistent state lives in /config; runtime files and caches go to /tmp
export HOME="/config"
export JUPYTER_CONFIG_DIR="/config/etc/jupyter"
export JUPYTER_DATA_DIR="/config/share/jupyter"
export JUPYTER_RUNTIME_DIR="/tmp/jupyter-runtime"
export IPYTHONDIR="/tmp/ipython"
export XDG_CACHE_HOME="/tmp/cache"

mkdir -p \
    "${JUPYTER_CONFIG_DIR}" \
    "${JUPYTER_DATA_DIR}" \
    "${JUPYTER_RUNTIME_DIR}" \
    "${IPYTHONDIR}" \
    "${XDG_CACHE_HOME}"

cd "/config" || exit 1

# JUPYTER_TOKEN is read from the environment by jupyter, so it stays out of the process list
exec \
    /app/venv/bin/jupyter lab \
        --ServerApp.ip=0.0.0.0 \
        --ServerApp.port="${JUPYTER_PORT:-8888}" \
        --ServerApp.root_dir=/config \
        --no-browser
