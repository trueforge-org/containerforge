#!/usr/bin/env bash
set -euo pipefail

# JSON data (account, holdings, settings) lives in /config/data, which api/data links to.
mkdir -p /config/data

# Upstream start-apache honours PORT; php -S gets the same value.
exec php -S "0.0.0.0:${PORT:-80}" -t /app/cryptofolio/website
