#!/usr/bin/env bash

mkdir -p /config/storage /config/originals /config/import

cd /opt/photoprism
# UNVERIFIED: binary path and "start" subcommand until the release tarball is listed.
exec /opt/photoprism/bin/photoprism start
