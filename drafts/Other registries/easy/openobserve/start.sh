#!/usr/bin/env bash

export ZO_DATA_DIR="${ZO_DATA_DIR:-/config/data}"
# UNVERIFIED: upstream runs `openobserve init-dir` at build time. The binary is assumed to create ZO_DATA_DIR itself.
mkdir -p "${ZO_DATA_DIR}"

cd /app || exit 1
exec /app/openobserve
