#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/collections

[[ -f /config/config ]] || cp /defaults/config /config/config

[[ -f /config/users ]] || install -m 600 /dev/null /config/users

# when both vars are set, (re)apply that user on every start; other entries are kept
if [[ -n "${RADICALE_USER:-}" && -n "${RADICALE_PASSWORD:-}" ]]; then
  case "$RADICALE_USER" in *:*|*$'\n'*) echo "RADICALE_USER must not contain ':' or newlines" >&2; exit 1;; esac
  /app/venv/bin/python - <<'PY'
import os
from passlib.hash import bcrypt
path, user = "/config/users", os.environ["RADICALE_USER"]
with open(path) as f:
    lines = [l for l in f.read().splitlines() if l.split(":", 1)[0] != user]
lines.append(f"{user}:{bcrypt.hash(os.environ['RADICALE_PASSWORD'])}")
tmp = path + ".new"
with open(os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600), "w") as f:
    f.write("\n".join(lines) + "\n")
os.replace(tmp, path)
PY
elif [[ ! -s /config/users ]]; then
  echo "radicale: no users configured; set RADICALE_USER/RADICALE_PASSWORD or add bcrypt entries to /config/users" >&2
fi

exec /app/venv/bin/python -m radicale --config "${RADICALE_CONFIG:-/config/config}"
