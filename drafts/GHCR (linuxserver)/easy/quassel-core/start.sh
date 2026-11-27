#!/usr/bin/env bash
set -euo pipefail

# State lives in /config (SQLite by default). Bind on all interfaces so clients in other containers can connect.
# UNVERIFIED: confirm the --listen and --port spellings with `quasselcore --help`.
# UNVERIFIED: the daemon is believed to stay in the foreground. If the container exits at once,
# check `--help` for a --nofork option. Do not add a flag that is not in --help.
exec quasselcore \
  --configdir=/config \
  --listen=0.0.0.0 \
  --port=4242
