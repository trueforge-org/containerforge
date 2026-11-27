#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export serverIP="${serverIP:-0.0.0.0}" # UNVERIFIED default, see settings.yaml
export serverPort="${serverPort:-8266}"

mkdir -p /config/configs /config/logs

if [ ! -w /temp ]; then
  echo "tdarr-node: /temp is not writable, mount a volume there" >&2
  exit 1
fi

cd /app/tdarr-node
# UNVERIFIED binary name, kept as the long-running process so signals reach it
exec ./Tdarr_Node
