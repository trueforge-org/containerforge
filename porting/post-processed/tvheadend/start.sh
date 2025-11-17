#!/usr/bin/env bash




# make folders
mkdir -p \
    /config/comskip

# copy config
if [[ ! -e /config/dvr/config ]]; then
    (mkdir -p /config/dvr/config && cp /defaults/7a5edfbe189851e5b1d1df19c93962f0 /config/dvr/config/7a5edfbe189851e5b1d1df19c93962f0)
fi
if [[ ! -e /config/comskip/comskip.ini ]]; then
    cp /defaults/comskip.ini.org /config/comskip/comskip.ini
fi
if [[ ! -e /config/config ]]; then
    (cp /defaults/config /config/config)
fi

# permissions
echo "Setting permissions"






FILES=$(find /dev/dri /dev/dvb -type c -print 2>/dev/null)

for i in $FILES
do
    VIDEO_GID=$(stat -c '%g' "$i")
    if id -G apps | grep -qw "$VIDEO_GID"; then
        touch /groupadd
    else
        if [ ! "${VIDEO_GID}" == '0' ]; then
            VIDEO_NAME=$(getent group "${VIDEO_GID}" | awk -F: '{print $1}')
            if [ -z "${VIDEO_NAME}" ]; then
                VIDEO_NAME="video$(head /dev/urandom | tr -dc 'a-z0-9' | head -c8)"
                groupadd "$VIDEO_NAME"
                groupmod -g "$VIDEO_GID" "$VIDEO_NAME"
            fi
            usermod -a -G "$VIDEO_NAME" apps
            touch /groupadd
        fi
    fi
done

if [ -n "${FILES}" ] && [ ! -f "/groupadd" ]; then
    usermod -a -G root apps
fi





exec \
    
         /usr/bin/tvheadend -C -c /config $RUN_OPTS

