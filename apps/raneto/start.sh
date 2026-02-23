#!/usr/bin/env bash


mkdir -p /config/{content,config,sessions}

# upgrade support
if [[ -f /config/config.default.js ]]; then
  mv /config/config.default.js /config/config/config.js
fi

# copy default config
if [[ ! -f /config/config/config.js ]]; then
    cp /defaults/config.js /config/config/config.js
fi

HOST=0.0.0.0
cd /app/raneto
exec node server.js
