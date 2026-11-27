#!/usr/bin/env bash
set -eu

[ -f /config/ankisyncd.toml ] || cp /defaults/ankisyncd.toml /config/ankisyncd.toml
export MAX_SYNC_PAYLOAD_MEGS="${MAX_SYNC_PAYLOAD_MEGS:-1000}"
cd /config

# The server panics at start-up when auth.db has no user (upstream 1.1.4 behaviour).
# UNVERIFIED: the exact output of `user --list` when empty; check at runtime.
users="$(/app/ankisyncd --config /config/ankisyncd.toml user --list 2>/dev/null || true)"
if [ -z "$users" ]; then
  export ANKISYNCD_USERNAME="${ANKISYNCD_USERNAME:-anki}"
  if [ -z "${ANKISYNCD_PASSWORD:-}" ]; then
    if [ ! -s /config/initial_password ]; then
      (umask 077; od -An -N16 -tx1 /dev/urandom | tr -d ' \n' > /config/initial_password)
    fi
    ANKISYNCD_PASSWORD="$(cat /config/initial_password)"
    export ANKISYNCD_PASSWORD
    echo "[anki-sync-server] No users yet: creating '${ANKISYNCD_USERNAME}', password in /config/initial_password" >&2
  fi
fi

exec /app/ankisyncd --config /config/ankisyncd.toml
