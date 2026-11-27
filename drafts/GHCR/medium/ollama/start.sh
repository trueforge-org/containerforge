#!/usr/bin/env bash

mkdir -p /config/data

# The secret key lives in /config so sessions survive restarts. It is generated once and never printed.
if [[ ! -s /config/webui-secret-key ]]; then
    (umask 077 && head -c 32 /dev/urandom | base64 > /config/webui-secret-key)
fi
WEBUI_SECRET_KEY="${WEBUI_SECRET_KEY:-$(cat /config/webui-secret-key)}"
export WEBUI_SECRET_KEY

# UNVERIFIED: DATA_DIR is the variable Open WebUI reads for its data folder; the upstream Dockerfile does not confirm it.
export DATA_DIR=/config/data

# Model caches are scratch data, so they go to /tmp and not /config.
export HF_HOME=/tmp/huggingface
export SENTENCE_TRANSFORMERS_HOME=/tmp/sentence-transformers

# UNVERIFIED: the open-webui serve CLI form; copy the real command from upstream backend/start.sh.
exec /app/venv/bin/open-webui serve --host 0.0.0.0 --port "${PORT:-8080}"
