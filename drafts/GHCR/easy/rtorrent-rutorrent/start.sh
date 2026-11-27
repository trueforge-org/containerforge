#!/usr/bin/env bash
set -euo pipefail

# The test runs without env vars, so a missing scrape URI only warns. Scrapes fail until it is set.
if [[ -z "${RTORRENT_EXPORTER_RTORRENT_SCRAPE_URI:-}" ]]; then
  echo "WARNING: RTORRENT_EXPORTER_RTORRENT_SCRAPE_URI is not set; rTorrent metrics will not be scraped." >&2
fi

# The binary reads its own RTORRENT_EXPORTER_* variables, so no flags are passed.
# UNVERIFIED: confirm the exporter starts without a scrape URI on the first run.
exec /app/rtorrent_exporter
