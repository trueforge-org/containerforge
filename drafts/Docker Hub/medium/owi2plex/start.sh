#!/usr/bin/env bash
set -eu

# Create only missing directories and files. Existing user copies in /config are never overwritten.
mkdir -p /config/owi2plex

if [ ! -f /config/crontab ]; then
  cp /defaults/crontab /config/crontab
fi

if [ ! -f /config/cronjob.sh ]; then
  cp /defaults/cronjob.sh /config/cronjob.sh
  chmod 0755 /config/cronjob.sh
fi

echo "owi2plex scheduler starting with /config/crontab"
exec supercronic /config/crontab
