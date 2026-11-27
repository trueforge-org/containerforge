#!/usr/bin/env bash
set -eu

# Document data lives under /config (docs.home is rewritten in docs.xml at build time).
mkdir -p /config/data

# The Jetty base stays in /app, where the modules were added at build time.
cd /app
exec java ${JAVA_OPTIONS:-} \
  -Djava.io.tmpdir=/tmp \
  -jar "${JETTY_HOME}/start.jar" \
  "jetty.http.port=8080" \
  "jetty.http.host=0.0.0.0"
