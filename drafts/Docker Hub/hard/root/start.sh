#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source /app/root/bin/thisroot.sh
set -u

NOTEBOOK_DIR="${JUPYTER_NOTEBOOK_DIR:-/config/notebooks}"
mkdir -p "${NOTEBOOK_DIR}" /config/jupyter /config/ipython /tmp/jupyter

# An empty JUPYTER_TOKEN disables authentication in Jupyter Server (UNVERIFIED for the installed version),
# so only keep it when it is set. Otherwise Jupyter generates a random token.
if [ -z "${JUPYTER_TOKEN:-}" ]; then
  unset JUPYTER_TOKEN
fi

exec /app/venv/bin/jupyter notebook \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --notebook-dir="${NOTEBOOK_DIR}"
