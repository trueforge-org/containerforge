#!/usr/bin/env bash

# create directories
mkdir -p \
    /config/{log,data/plugins/configurations,data/transcodes,cache} \
    /data \
    /transcode

# openmax lib loading
if [[ -e "/opt/vc/lib" ]] && [[ ! -e "/etc/ld.so.conf.d/00-vmcs.conf" ]]; then
    echo "[jellyfin-init] Pi Libs detected loading"
    echo "/opt/vc/lib" > "/etc/ld.so.conf.d/00-vmcs.conf"
    ldconfig
fi

if [[ -z "${FFMPEG_PATH}" ]] || [[ ! -f "${FFMPEG_PATH}" ]]; then
    FFMPEG_PATH=/usr/lib/jellyfin-ffmpeg/ffmpeg
fi

export \
    HOME="/config" \
    JELLYFIN_DATA_DIR="/config/data" \
    JELLYFIN_CONFIG_DIR="/config" \
    JELLYFIN_LOG_DIR="/config/log" \
    JELLYFIN_CACHE_DIR="/config/cache" \
    JELLYFIN_WEB_DIR="/usr/share/jellyfin/web"

exec \
            /usr/bin/jellyfin \
        --ffmpeg="${FFMPEG_PATH}"

