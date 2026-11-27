#!/usr/bin/env bash
set -euo pipefail

# OpenAudible is packaged for amd64 only (the image build enforces this too).
if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "OpenAudible is only available for x86_64" >&2
  exit 1
fi

# Persistent library and settings live under /config; cache is ephemeral.
mkdir -p /config/OpenAudible /tmp/.cache
echo "OpenAudible ${OPENAUDIBLE_VERSION:-5.3} (amd64)"

# Hand over to the KasmVNC base start script (saved at build time), which starts the desktop and nginx.
exec /usr/local/bin/kasmvnc-start.sh "$@"
