#!/usr/bin/env bash
set -euo pipefail

# Create the model cache directory only when missing. Models download here on first use.
mkdir -p "${ASR_MODEL_PATH:-/config/cache/whisper}"

# Upstream entrypoint is the whisper-asr-webservice console script (app.webservice:start).
cd /app
exec /app/venv/bin/whisper-asr-webservice --host 0.0.0.0 --port 9000
