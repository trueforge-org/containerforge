#!/usr/bin/env bash

# kromgo reads /config/config.yaml by default. Seed nothing: the operator provides the file.
mkdir -p /config

cd /config
exec /app/kromgo
