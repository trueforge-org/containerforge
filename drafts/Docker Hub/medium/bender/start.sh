#!/usr/bin/env bash

# /app/static is a symlink to /config/static, so state lives in /config
mkdir -p /config/static

# seed defaults only when config.json is missing; cp -n never overwrites
if [[ "${INIT_ASSETS:-1}" == "1" && ! -f /config/static/config.json ]]; then
  cp -rn /app/static-default/. /config/static/
  cp -n /app/static-default/config.json.default /config/static/config.json
fi

# call the binary directly so npm does not write logs or cache into $HOME
cd /app || exit 1
exec /app/node_modules/.bin/nuxt start
