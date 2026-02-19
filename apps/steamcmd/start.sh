#!/usr/bin/env bash
set -euo pipefail

export HOME=/config
export XDG_DATA_HOME=/config

mkdir -p /config/steamcmd

if [ ! -f /config/Steam/steamcmd/steamcmd.sh ]; then
    mkdir -p /config/Steam/steamcmd/linux32
    cp /usr/lib/games/steam/steamcmd.sh /config/Steam/steamcmd/
    cp /usr/lib/games/steam/steamcmd /config/Steam/steamcmd/linux32/
fi

cd /config/steamcmd
exec /config/Steam/steamcmd/steamcmd.sh "$@"
