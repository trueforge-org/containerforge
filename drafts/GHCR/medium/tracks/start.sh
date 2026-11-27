#!/usr/bin/env bash
set -euo pipefail

# /app is read-only at runtime. Logs and Rails tmp are symlinks to /tmp (set up at build time).
mkdir -p /config /tmp/log /tmp/rails-tmp

# Secret key: keep a generated one in /config unless SECRET_KEY_BASE is set.
if [[ -z "${SECRET_KEY_BASE:-}" ]]; then
  if [[ ! -s /config/secret_key_base ]]; then
    umask 077
    # openssl is assumed present in the base image (UNVERIFIED)
    openssl rand -hex 64 > /config/secret_key_base
  fi
  SECRET_KEY_BASE="$(cat /config/secret_key_base)"
fi
export SECRET_KEY_BASE

# Database settings from the environment, as upstream docker-entrypoint.sh does.
: "${DATABASE_TYPE:=mysql2}"
: "${DATABASE_HOST:=mariadb}"
: "${DATABASE_PORT:=3306}"
: "${DATABASE_NAME:=tracks}"
: "${DATABASE_USERNAME:=tracks}"
: "${DATABASE_ENCODING:=utf8}"
export DATABASE_TYPE DATABASE_HOST DATABASE_PORT DATABASE_NAME DATABASE_USERNAME DATABASE_ENCODING
export DATABASE_PASSWORD="${DATABASE_PASSWORD:-}"

export RAILS_ENV=production
cd /app

bundle exec rails db:prepare

exec bundle exec rails server -b 0.0.0.0 -p 3000
