#!/usr/bin/env bash
set -euo pipefail

export MALOJA_DATA_DIRECTORY="${MALOJA_DATA_DIRECTORY:-/config}"
export MALOJA_SKIP_SETUP="${MALOJA_SKIP_SETUP:-yes}"

# Maloja creates its own files under the data directory on first start
mkdir -p "${MALOJA_DATA_DIRECTORY}"
cd "${MALOJA_DATA_DIRECTORY}"

# Same command as upstream container/root svc-python run script (v3.2.10)
exec /app/maloja/venv/bin/python -m maloja run
