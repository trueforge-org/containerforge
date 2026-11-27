#!/usr/bin/env bash
set -eu

umask "${SLSKD_UMASK:-0022}"

export SLSKD_DOWNLOADS_DIR="${SLSKD_DOWNLOADS_DIR:-/config/downloads}"
export SLSKD_INCOMPLETE_DIR="${SLSKD_INCOMPLETE_DIR:-/config/incomplete}"

mkdir -p "${SLSKD_DOWNLOADS_DIR}" "${SLSKD_INCOMPLETE_DIR}"

# The Soulseek password is passed only through the environment, never as an argument.
exec /app/slskd
