#!/usr/bin/env bash

set -e

exec node index "$@" | /app/app/node_modules/.bin/bunyan -L  -o short
