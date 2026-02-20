#!/usr/bin/env bash


if [ -n "${AUTH_LIST}" ]; then
    export authentication__mechanism='["plex"]'
    export authentication__type='["server", "user"]'
    export authentication__authorized="[\"$(echo ${AUTH_LIST} | sed 's|,|", "|g')\"]"
fi


exec synclounge

