#!/usr/bin/env bash
# Replaces upstream docker-entrypoint.sh, which runs as root, chowns the data
# directory and drops to nextjs with gosu. This image already runs as apps.

mkdir -p /config/data /config/workflow

# Seed the JWT secret once; never overwrite an existing one.
# UNVERIFIED: upstream README says the app can generate its own secret into its
# data directory when JWT_SECRET is unset. If that works on /config/data, this
# block can be dropped.
if [[ -z "${JWT_SECRET:-}" ]]; then
  if [[ ! -s /config/jwt_secret ]]; then
    umask 077
    # UNVERIFIED: openssl is present in the base image (check in build step).
    openssl rand -hex 32 > /config/jwt_secret
  fi
  JWT_SECRET="$(< /config/jwt_secret)"
fi
export JWT_SECRET

export PORT="${PORT:-3000}"
export HOSTNAME="${HOSTNAME:-0.0.0.0}"

cd /app || exit 1
exec node server.js
