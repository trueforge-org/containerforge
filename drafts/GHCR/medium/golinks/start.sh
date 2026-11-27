#!/bin/sh
set -eu

# UNVERIFIED: the upstream start script at v0.0.7 was not read; this follows master
mkdir -p /config

BIND="${BIND:-0.0.0.0:8000}"
BASEURL="${BASEURL:-http://localhost:8000}"
DBPATH="${DBPATH:-/config/search.db}"
TITLE="${TITLE:-Search}"
SEARCHURL="${SEARCHURL:-https://www.google.com/search?q=%s&btnK}"
SUGGESTURL="${SUGGESTURL:-https://suggestqueries.google.com/complete/search?client=firefox&q=%s}"
CONFIG="${CONFIG-}"

if [ -n "$CONFIG" ]; then
  echo "Executing golinks with config file: ${CONFIG}"
  exec /app/golinks/golinks -config "$CONFIG"
fi

echo "Executing golinks on ${BIND}"
exec /app/golinks/golinks -bind="$BIND" -baseURL="$BASEURL" -dbpath="$DBPATH" \
  -title="$TITLE" -searchURL="$SEARCHURL" -suggestURL="$SUGGESTURL"
