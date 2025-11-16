# ===== From ./processed/jellyfin/root/etc/s6-overlay//s6-rc.d/init-jellyfin-config/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# create directories
mkdir -p \
    /config/{log,data/plugins/configurations,data/transcodes,cache} \
    /data \
    /transcode

# permissions
lsiown abc:abc \
    /config \
    /config/* \
    /config/data/plugins \
    /config/data/plugins/configurations \
    /config/data/transcodes \
    /transcode

# ===== From ./processed/jellyfin/root/etc/s6-overlay//s6-rc.d/init-jellyfin-video/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

FILES=$(find /dev/dri /dev/dvb /dev/vchiq /dev/vc-mem /dev/video1? -type c -print 2>/dev/null)

for i in ${FILES}; do
    VIDEO_GID=$(stat -c '%g' "${i}")
    VIDEO_UID=$(stat -c '%u' "${i}")
    # check if user matches device
    if id -u abc | grep -qw "${VIDEO_UID}"; then
        echo "**** permissions for ${i} are good ****"
    else
        # check if group matches and that device has group rw
        if id -G abc | grep -qw "${VIDEO_GID}" && [[ $(stat -c '%A' "${i}" | cut -b 5,6) == "rw" ]]; then
            echo "**** permissions for ${i} are good ****"
        # check if device needs to be added to video group
        elif ! id -G abc | grep -qw "${VIDEO_GID}"; then
            # check if video group needs to be created
            VIDEO_NAME=$(getent group "${VIDEO_GID}" | awk -F: '{print $1}')
            if [[ -z "${VIDEO_NAME}" ]]; then
                VIDEO_NAME="video$(head /dev/urandom | tr -dc 'a-z0-9' | head -c4)"
                groupadd "${VIDEO_NAME}"
                groupmod -g "${VIDEO_GID}" "${VIDEO_NAME}"
                echo "**** creating video group ${VIDEO_NAME} with id ${VIDEO_GID} ****"
            fi
            echo "**** adding ${i} to video group ${VIDEO_NAME} with id ${VIDEO_GID} ****"
            usermod -a -G "${VIDEO_NAME}" abc
        fi
        # check if device has group rw
        if [[ $(stat -c '%A' "${i}" | cut -b 5,6) != "rw" ]]; then
            echo -e "**** The device ${i} does not have group read/write permissions, attempting to fix inside the container. ****"
            chmod g+rw "${i}"
        fi
    fi
done

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
    s6-notifyoncheck -d -n 300 -w 1000 \
        s6-setuidgid abc /usr/bin/jellyfin \
        --ffmpeg="${FFMPEG_PATH}"

