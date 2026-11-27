#!/usr/bin/env bash

# Persistent state lives in /config through the symlinks made at build time.
mkdir -p /config/storage/db /config/custom_config /config/ssl

# UNVERIFIED: whether the app starts on its built-in defaults with an empty /config.
cd /app/crypto-exchanges-gateway
exec node ./gateway.js
