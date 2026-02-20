#!/usr/bin/with-contenv bash
# shellcheck shell=bash

python3 /app/venv/bin/feed2toot -l "${FEED_LIMIT:-5}" -c /config/feed2toot.ini
