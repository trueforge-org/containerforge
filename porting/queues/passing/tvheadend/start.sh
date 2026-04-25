#!/usr/bin/env bash

# check if /config is writable
if [[ -w /config ]]; then
    # make folders
    mkdir -p /config/comskip

    # copy config
    if [[ ! -e /config/dvr/config ]]; then
        (mkdir -p /config/dvr/config && cp /defaults/7a5edfbe189851e5b1d1df19c93962f0 /config/dvr/config/7a5edfbe189851e5b1d1df19c93962f0)
    fi
    if [[ ! -e /config/comskip/comskip.ini ]]; then
        cp /defaults/comskip.ini.org /config/comskip/comskip.ini
    fi
    if [[ ! -e /config/config ]]; then
        (cp /defaults/config /config/config)
    fi
else
    # use /tmp fallback when /config is readonly
    echo "Warning: /config is read-only, using /tmp for runtime config"
    mkdir -p /tmp/tvh/comskip /tmp/tvh/dvr/config
    [ -f /defaults/7a5edfbe189851e5b1d1df19c93962f0 ] && cp /defaults/7a5edfbe189851e5b1d1df19c93962f0 /tmp/tvh/dvr/config/
    [ -f /defaults/comskip.ini.org ] && cp /defaults/comskip.ini.org /tmp/tvh/comskip/comskip.ini
    [ -f /defaults/config ] && cp /defaults/config /tmp/tvh/config
    export HOME=/tmp/tvh
fi

exec /usr/bin/tvheadend -C -c "${HOME:-/config}" $RUN_OPTS
