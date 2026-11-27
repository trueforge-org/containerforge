#!/usr/bin/env bash
# Wallet preparation, then the kasmvnc base start logic. The Dockerfile moves the base start.sh to
# /kasmvnc-start.sh. The base seeds /config/.config/openbox/autostart from /defaults/autostart,
# which launches the wallet.
set -euo pipefail

export HOME=/config

# Data directory for the wallet. The wallet uses ~/.GridcoinResearch, which is /config/.GridcoinResearch.
mkdir -p /config/.GridcoinResearch

exec /kasmvnc-start.sh "$@"
