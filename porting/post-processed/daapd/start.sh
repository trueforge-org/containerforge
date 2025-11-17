#!/usr/bin/env bash




FILES=$(find /dev/snd -type c -print 2>/dev/null)

for i in ${FILES}
do
    AUDIO_UID=$(stat -c '%u' "${i}")
    AUDIO_GID=$(stat -c '%g' "${i}")
    # check if user matches device
    if id -u apps | grep -qw "${AUDIO_UID}"; then
        echo "---permissions for ${i} are good---"
    else
        # check if group matches and that device has group rw
        if id -G apps | grep -qw "${AUDIO_GID}" && [ "$(stat -c '%A' "${i}" | cut -b 5,6)" = "rw" ]; then
            echo "---permissions for ${i} are good---"
        # check if device needs to be added to video group
        elif ! id -G apps | grep -qw "${AUDIO_GID}"; then
            # check if video group needs to be created
            GROUP_NAME=$(getent group "${AUDIO_GID}" | awk -F: '{print $1}')
            if [ -z "${GROUP_NAME}" ]; then
                GROUP_NAME="audio-$(head /dev/urandom | tr -dc 'a-z0-9' | head -c4)"
                groupadd "${GROUP_NAME}"
                groupmod -g "${AUDIO_GID}" "${GROUP_NAME}"
                echo "---creating audio group ${GROUP_NAME} with id ${AUDIO_GID}---"
            fi
            echo "---adding ${i} to audio group ${GROUP_NAME} with id ${AUDIO_GID}---"
            usermod -a -G "${GROUP_NAME}" apps
        fi
        # check if device has group rw
        if [ "$(stat -c '%A' "${i}" | cut -b 5,6)" != "rw" ]; then
            echo -e "---The device ${i} does not have group read/write permissions, attempting to fix inside the container.---"
            chmod g+rw "${i}"
        fi
    fi
done





# make our folders
mkdir -p \
    /var/run/dbus \
    /run/dbus \
    /config/dbase_and_logs \
    /daapd-pidfolder


if [[ -e /var/run/dbus.pid ]]; then
    rm -f /var/run/dbus.pid
fi

if [[ -e /run/dbus/dbus.pid ]]; then
    rm -f /run/dbus/dbus.pid
fi

dbus-uuidgen --ensure
sleep 1

# configure defaults copy of conf
if [[ ! -e "/defaults/owntone.conf" ]]; then
cp /etc/owntone.conf.orig /defaults/owntone.conf
sed -i \
    -e '/cache_path\ =/ s/# *//' \
    -e '/db_path\ =/ s/# *//' \
    -e s#ipv6\ =\ yes#ipv6\ =\ no#g \
    -e s#My\ Music\ on\ %h#LS.IO\ Music#g \
    -e s#/srv/music#/music#g \
    -e 's/\(uid.*=\).*/\1 \"apps\"/g' \
    -e s#/var/cache/owntone/cache.db#/config/dbase_and_logs/cache.db#g \
    -e s#/var/cache/owntone/songs3.db#/config/dbase_and_logs/songs3.db#g \
    -e s#/var/log/owntone.log#/config/dbase_and_logs/owntone.log#g \
    -e '/trusted_networks\ =/ s/# *//' \
    -e 's#trusted_networks = {.*#trusted_networks = { "lan" }#' \
    -e '/admin_password\ =/ s/# *//' \
    -e 's#admin_password = .*#admin_password = "changeme"#' \
    /defaults/owntone.conf
fi

# symlink conf to /conf
if [[ ! -f /config/owntone.conf ]]; then
    cp /defaults/owntone.conf /config/owntone.conf
fi

if [[ ! -L /etc/owntone.conf && -f /etc/owntone.conf ]]; then
    rm /etc/owntone.conf
fi

if [[ ! -L /etc/owntone.conf ]]; then
    ln -s /config/owntone.conf /etc/owntone.conf
fi

# permissions

    /app \
    /config \
    /daapd-pidfolder






until [[ -e /var/run/dbus/system_bus_socket ]]; do
    sleep 1s
done

exec \
    avahi-daemon --no-chroot





exec \
    dbus-daemon --system --nofork







exec \
     /usr/sbin/owntone -f \
    -P /daapd-pidfolder/owntone.pid


#!/usr/bin/execlineb -P

librespot --backend pipe --device /music/spotify -n forked-daapd --cache /tmp

