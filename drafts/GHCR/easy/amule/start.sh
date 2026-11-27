#!/usr/bin/env bash
set -euo pipefail

# HOME=/config puts amule's data in /config/.aMule (UNVERIFIED default path).
export HOME=/config
mkdir -p /config/.aMule /config/downloads/incoming /config/downloads/temp
cd /config

# OPEN: the chart's WEBUI_PWD and GUI_PWD are not applied yet. amule.conf key names and
# password hashing are UNVERIFIED, so no password is set by this draft.
# UNVERIFIED: amuled runs in the foreground when started this way; check on the first run.
# amuleweb is not started here. Decide whether the web UI runs in the same container.
exec amuled
