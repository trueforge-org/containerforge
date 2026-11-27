#!/usr/bin/env bash

mkdir -p /config

cd /app || exit 1

# entrypoint.mjs seeds settings.yml and auth.yaml under /config when missing (UNVERIFIED, read it at v6.1.2).
exec node entrypoint.mjs
