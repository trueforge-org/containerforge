# ===== From ./processed/jellyfin/root/etc/s6-overlay//s6-rc.d/init-jellyfin-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# create directories
mkdir -p \
    /config/{log,data/plugins/configurations,data/transcodes,cache} \
    /data \
    /transcode

# ===== From ./processed/jellyfin/root/etc/s6-overlay//s6-rc.d/init-jellyfin-video/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash



# openmax lib loading
if [[ -e "/opt/vc/lib" ]] && [[ ! -e "/etc/ld.so.conf.d/00-vmcs.conf" ]]; then
    echo "[jellyfin-init] Pi Libs detected loading"
    echo "/opt/vc/lib" > "/etc/ld.so.conf.d/00-vmcs.conf"
    ldconfig
fi

# ===== From ./processed/jellyfin/root/etc/s6-overlay//s6-rc.d/svc-jellyfin/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

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

