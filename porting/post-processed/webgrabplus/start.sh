#!/usr/bin/env bash


mkdir -p \
    /app/wg++/bin.net/WebGrab+Plus \
    /config/License
ln -sf /config/License /app/wg++/bin.net/WebGrab+Plus

# copy config
if [[ ! -e /config/WebGrab++.config.xml ]]; then
    cp /defaults/WebGrab++.config.xml /config/
fi

if [[ ! -e /config/siteini.pack ]]; then
    cp -R /defaults/ini/siteini.pack /config/
fi

## TODO: figure out exec
