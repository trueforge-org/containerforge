#!/bin/sh
# Initial draft wrapper around abusesa/github-backup (backup.py reads a JSON config file).
# Idempotent. Runs as the apps user. Never writes to /app. The generated config (with the token) lives on /tmp.
set -eu

BACKUP_DIR="${BACKUP_DIR:-/config/backups}"
BACKUP_INTERVAL_SECONDS="${BACKUP_INTERVAL_SECONDS:-0}"
CONFIG=/tmp/github-backup.json

mkdir -p "$BACKUP_DIR"

# Read the token from GITHUB_TOKEN or GITHUB_TOKEN_FILE (secret mount).
TOKEN="${GITHUB_TOKEN:-}"
if [ -z "$TOKEN" ] && [ -n "${GITHUB_TOKEN_FILE:-}" ] && [ -r "$GITHUB_TOKEN_FILE" ]; then
    TOKEN="$(cat "$GITHUB_TOKEN_FILE")"
fi

if [ -z "$TOKEN" ]; then
    echo "no GitHub token set (GITHUB_TOKEN or GITHUB_TOKEN_FILE), idling"
    trap 'exit 0' INT TERM
    while :; do sleep 3600 & wait $!; done
fi

# Build the JSON config with python so special characters in the token or owners are escaped.
umask 077
GH_TOKEN_VALUE="$TOKEN" GH_OWNERS="${GITHUB_OWNERS:-}" GH_DIR="$BACKUP_DIR" CONFIG_PATH="$CONFIG" \
    python3 -I -c '
import json, os
owners = [o.strip() for o in os.environ.get("GH_OWNERS", "").split(",") if o.strip()]
cfg = {"token": os.environ["GH_TOKEN_VALUE"], "directory": os.environ["GH_DIR"]}
if owners:
    cfg["owners"] = owners
with open(os.environ["CONFIG_PATH"], "w") as f:
    json.dump(cfg, f)
'
unset TOKEN

run_backup() {
    python3 /app/github-backup/backup.py "$CONFIG"
}

if [ "$BACKUP_INTERVAL_SECONDS" -gt 0 ]; then
    trap 'exit 0' INT TERM
    while :; do
        run_backup || echo "backup run failed, retrying after interval" >&2
        sleep "$BACKUP_INTERVAL_SECONDS" & wait $!
    done
fi

run_backup
echo "backup run finished, idling"
trap 'exit 0' INT TERM
while :; do sleep 3600 & wait $!; done
