#!/usr/bin/env bash

cd /app/www/server || exit 1

exec /usr/bin/node index.js

