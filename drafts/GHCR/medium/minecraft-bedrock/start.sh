#!/usr/bin/env bash

if [[ "${EULA:-}" != "TRUE" ]]; then
  echo "EULA must be set to TRUE to run the Minecraft Bedrock server (https://www.minecraft.net/en-us/eula)." >&2
  exit 1
fi

# server files live under /config (persistent); downloads and scratch go to /tmp
mkdir -p /config/bedrock /tmp/bedrock-downloads
cd /config/bedrock || exit 1

export HOME=/config/bedrock
export DOWNLOAD_DIR=/tmp/bedrock-downloads
export TMPDIR=/tmp

exec /etc/bedrock-entry.sh
