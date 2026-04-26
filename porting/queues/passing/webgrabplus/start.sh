#!/usr/bin/env bash


mkdir -p \
    /config/License

# copy config
if [[ ! -e /config/WebGrab++.config.xml ]]; then
    cp /root/defaults/WebGrab++.config.xml /config/
fi

if [[ ! -e /config/siteini.pack ]]; then
    cp -R /defaults/ini/siteini.pack /config/
fi

exec /app/dotnet/dotnet /app/wg++/bin.net/WebGrab+Plus.dll /config
