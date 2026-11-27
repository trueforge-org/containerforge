#!/usr/bin/env bash
set -eu

# Database and attachments live under /config/data (DB_URI, ATTACHMENTS_PATH).
# UNVERIFIED: whether `serve` runs DB migrations on start; check before release.
mkdir -p /config/data/attachments

cd /app
exec ./hasty-paste serve
