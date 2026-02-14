#!/usr/bin/env bash


# copy config
cp -n /defaults/beets.sh /config/beets.sh
cp -n /defaults/config.yaml /config/config.yaml

chmod +x /config/beets.sh

exec beet web
