#!/usr/bin/env bash
set -euo pipefail

# Custom models (*.tflite) go in OWW_CUSTOM_MODEL_DIR. Built-in models come from the pyopen-wakeword package.
CUSTOM_MODEL_DIR="${OWW_CUSTOM_MODEL_DIR:-/config/custom}"
mkdir -p "${CUSTOM_MODEL_DIR}"

# OWW_DEBUG adds --debug when non-empty. The variable is intentionally left unquoted so the flag disappears when unset.
DEBUG_FLAG=()
if [ -n "${OWW_DEBUG:-}" ]; then
  DEBUG_FLAG=(--debug)
fi

exec /app/venv/bin/python -m wyoming_openwakeword \
  --uri 'tcp://0.0.0.0:10400' \
  --custom-model-dir "${CUSTOM_MODEL_DIR}" \
  --threshold "${OWW_THRESHOLD:-0.5}" \
  --trigger-level "${OWW_TRIGGER_LEVEL:-1}" \
  --refractory-seconds "${OWW_REFRACTORY_SECONDS:-2}" \
  "${DEBUG_FLAG[@]}"
