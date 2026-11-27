#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config/database /config/logs

# Seed the config templates only when missing or empty, so user edits survive restarts
for name in clamd.conf freshclam.conf; do
  if [[ ! -s "/config/${name}" ]]; then
    cp "/defaults/${name}" "/config/${name}"
  fi
done

# clamd does not start without signature databases, so fetch them first (needs internet on first start)
if [[ ! -f /config/database/main.cvd && ! -f /config/database/main.cld ]]; then
  echo "No signature database found, running freshclam once (first start can take several minutes)"
  freshclam --config-file=/config/freshclam.conf
fi

# Keep the database fresh in the background unless disabled
if [[ "${CLAMAV_NO_FRESHCLAMD:-false}" != "true" ]]; then
  freshclam -d --foreground=true --stdout --checks="${FRESHCLAM_CHECKS:-1}" --config-file=/config/freshclam.conf &
fi

# A stale socket from a previous run would block clamd from binding
rm -f /tmp/clamd.sock

# exec so clamd gets the signals. freshclam is a background child. UNVERIFIED that tini signals the whole group on stop.
exec clamd --foreground --config-file=/config/clamd.conf
