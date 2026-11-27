#!/usr/bin/env bash
set -euo pipefail

for v in APP_HOST APP_DOMAIN APP_PASSWORD; do
  if [[ -z "${!v:-}" ]]; then
    echo "[namecheap-ddns] ${v} is required (use ';' to separate multiple hosts/domains/passwords)" >&2
    exit 1
  fi
done

# RISK (decide before release): upstream puts APP_PASSWORD in the request URL and logs exception text,
# which can expose the password in logs. Do not log it in start.sh.
export PYTHONDONTWRITEBYTECODE=1
cd /app/namecheap-ddns
exec /app/venv/bin/python -u /app/namecheap-ddns/main.py
