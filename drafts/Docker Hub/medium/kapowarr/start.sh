#!/usr/bin/env bash
set -euo pipefail

export TMPDIR=/tmp

mkdir -p /config

# App path (Kapowarr.py) and the data path (db, temp downloads) are UNVERIFIED until the V1.3.2 source is read.
# Remap them to /config once confirmed (plan sections 7 and 9).
cd /app/kapowarr
exec /app/venv/bin/python /app/kapowarr/Kapowarr.py
