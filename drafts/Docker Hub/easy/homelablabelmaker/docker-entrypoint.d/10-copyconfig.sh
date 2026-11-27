#!/usr/bin/env bash

echo "[10-copyconfig] Seeding nginx site config for homelablabelmaker"
mkdir -p /config/sites
# Seed once, then leave user edits alone.
if [ ! -f /config/sites/.homelablabelmaker-seeded ]; then
  cp /defaults/default.conf /config/sites/default.conf
  touch /config/sites/.homelablabelmaker-seeded
fi
