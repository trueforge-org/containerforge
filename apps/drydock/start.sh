#!/usr/bin/env bash
set -e

COMPOSE_DIR="${COMPOSE_DIR:-''}"
COMPOSE_THRESHOLD="${THRESHOLD:-minor}"

node index "$@" | /app/node_modules/.bin/bunyan -L -o short
