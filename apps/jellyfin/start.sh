#!/usr/bin/env bash



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
    JELLYFIN_DATA_DIR=${JELLYFIN_DATA_DIR:="/config/data"} \
    JELLYFIN_CONFIG_DIR=${JELLYFIN_CONFIG_DIR:="/config"} \
    JELLYFIN_LOG_DIR=${JELLYFIN_LOG_DIR:="/config/log"} \
    JELLYFIN_CACHE_DIR=${JELLYFIN_CACHE_DIR:="/config/cache"} \
    JELLYFIN_WEB_DIR=${JELLYFIN_WEB_DIR:="/usr/share/jellyfin/web"}

# create directories
mkdir -p \
    $JELLYFIN_CONFIG_DIR "$JELLYFIN_DATA_DIR/plugins/configurations" "$JELLYFIN_DATA_DIR/transcodes" "$JELLYFIN_LOG_DIR" "$JELLYFIN_CACHE_DIR" || true

exec /usr/bin/jellyfin \
        --ffmpeg="${FFMPEG_PATH}"

