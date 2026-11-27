#!/usr/bin/env bash

APP_PORT="${APP_PORT:-3000}"
ENABLE_REGISTRATIONS="${ENABLE_REGISTRATIONS:-false}"
MYSQL_HOST="${MYSQL_HOST:-mariadb}"
MYSQL_USERNAME="${MYSQL_USERNAME:-clarkson}"

if [[ -z "${MYSQL_PASSWORD:-}" ]]; then
  echo "clarkson: MYSQL_PASSWORD is not set, database access will fail" >&2
fi

# UNVERIFIED: FLYWAY_* env vars are honoured by the bundled flyway, so the password stays off argv
export FLYWAY_USER="${MYSQL_USERNAME}"
export FLYWAY_PASSWORD="${MYSQL_PASSWORD:-}"
export FLYWAY_URL="jdbc:mysql://${MYSQL_HOST}"
export FLYWAY_SCHEMAS=clarkson

cd /app/clarkson || exit 1

# flyway is idempotent; a failed migration is logged and the app still starts
./flyway/flyway migrate || \
  echo "clarkson: flyway migrate failed, is ${MYSQL_HOST} reachable? continuing" >&2

export APP_PORT ENABLE_REGISTRATIONS MYSQL_HOST MYSQL_USERNAME MYSQL_PASSWORD
exec node clarkson.js
