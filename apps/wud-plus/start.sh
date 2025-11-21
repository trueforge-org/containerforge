#!/usr/bin/env bash

set -e

exec node index "$@" | /app/node_modules/.bin/bunyan -L  -o short
