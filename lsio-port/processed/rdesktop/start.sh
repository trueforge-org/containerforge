# ===== From ./processed/rdesktop/root/etc/s6-overlay//s6-rc.d/init-keygen/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [[ ! -f "/keylock" ]]; then
    cd /etc/xrdp || exit 1
    xrdp-keygen xrdp
    rm -f /etc/xrdp/*.pem
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout /etc/xrdp/key.pem \
    -out /etc/xrdp/cert.pem \
    -subj "/C=US/ST=CA/L=Carlsbad/O=Linuxserver.io/OU=LSIO Server/CN=*"
    touch /keylock
fi

# ===== From ./processed/rdesktop/root/etc/s6-overlay//s6-rc.d/init-prep-xrdp/run =====
#!/usr/bin/with-contenv bash

mkdir -p /var/run/xrdp || exit 1
chown root:xrdp /var/run/xrdp || exit 1
chmod 2775 /var/run/xrdp || exit 1

mkdir -p /var/run/xrdp/sockdir || exit 1
chown root:xrdp /var/run/xrdp/sockdir || exit 1
chmod 3777 /var/run/xrdp/sockdir || exit 1

# ===== From ./processed/rdesktop/root/etc/s6-overlay//s6-rc.d/init-rdesktop/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# default file copies first run
if [[ ! -d /config/.config ]]; then
  mkdir -p /config/.config
  cp /defaults/bashrc /config/.bashrc
  cp /defaults/startwm.sh /config/startwm.sh
fi
if [[ ! -f /config/.config/openbox/autostart ]]; then
  mkdir -p /config/.config/openbox
  cp /defaults/autostart /config/.config/openbox/autostart
fi
if [[ ! -f /config/.config/openbox/menu.xml ]]; then
  mkdir -p /config/.config/openbox 
  cp /defaults/menu.xml /config/.config/openbox/menu.xml 
fi

# XDG Home
printf "/config/.XDG" > /run/s6/container_environment/XDG_RUNTIME_DIR
if [ ! -d "/config/.XDG" ]; then
  mkdir -p /config/.XDG
  chown abc:abc /config/.XDG
fi

# Locale Support
if [ ! -z ${LC_ALL+x} ]; then
  printf "${LC_ALL%.UTF-8}" > /run/s6/container_environment/LANGUAGE
  printf "${LC_ALL}" > /run/s6/container_environment/LANG
fi

# Remove window borders
if [[ ! -z ${NO_DECOR+x} ]] && [[ ! -f /decorlock ]]; then
  sed -i \
    's|</applications>|  <application class="*"> <decor>no</decor> </application>\n</applications>|' \
    /etc/xdg/openbox/rc.xml
  touch /decorlock
fi

# Fullscreen everything in openbox unless the user explicitly disables it
if [[ ! -z ${NO_FULL+x} ]] && [[ ! -f /fulllock ]]; then
  sed -i \
    '/<application class="\*"><maximized>yes<\/maximized><\/application>/d' \
    /etc/xdg/openbox/rc.xml
  touch /fulllock
fi

# Add proot-apps
if [ ! -f "/config/.local/bin/proot-apps" ]; then
  mkdir -p /config/.local/bin/
  cp /proot-apps/* /config/.local/bin/
  echo 'export PATH="/config/.local/bin:$PATH"' >> /config/.bashrc
  chown abc:abc \
    /config/.bashrc \
    /config/.local/ \
    /config/.local/bin \
    /config/.local/bin/{ncat,proot-apps,proot,jq,pversion}
elif ! diff -q /proot-apps/pversion /config/.local/bin/pversion > /dev/null; then
  cp /proot-apps/* /config/.local/bin/
  chown abc:abc /config/.local/bin/{ncat,proot-apps,proot,jq,pversion}
fi

# permissions
PERM=$(stat -c '%U' /config/.config)
if [[ "${PERM}" != "abc" ]]; then
    chown -R abc:abc /config
fi

# ===== From ./processed/rdesktop/root/etc/s6-overlay//s6-rc.d/init-video/run =====
#!/usr/bin/with-contenv bash
# shellcheck shell=bash

FILES=$(find /dev/dri /dev/dvb -type c -print 2>/dev/null)

for i in $FILES
do
    VIDEO_GID=$(stat -c '%g' "${i}")
    VIDEO_UID=$(stat -c '%u' "${i}")
    # check if user matches device
    if id -u abc | grep -qw "${VIDEO_UID}"; then
        echo "**** permissions for ${i} are good ****"
    else
        # check if group matches and that device has group rw
        if id -G abc | grep -qw "${VIDEO_GID}" && [[ $(stat -c '%A' "${i}" | cut -b 5,6) = "rw" ]]; then
            echo "**** permissions for ${i} are good ****"
        # check if device needs to be added to video group
        elif ! id -G abc | grep -qw "${VIDEO_GID}"; then
            # check if video group needs to be created
            VIDEO_NAME=$(getent group "${VIDEO_GID}" | awk -F: '{print $1}')
            if [ -z "${VIDEO_NAME}" ]; then
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
            echo -e "**** The device ${i} does not have group read/write permissions, attempting to fix inside the container.If it doesn't work, you can run the following on your docker host: ****\nsudo chmod g+rw ${i}\n"
            chmod g+rw "${i}"
        fi
    fi
done

# ===== From ./processed/rdesktop/root/etc/s6-overlay//s6-rc.d/svc-xrdp/run =====
#! /usr/bin/execlineb -P

# Move stderr to out so it's piped to logger
fdmove -c 2 1

# Notify service manager when xrdp is up
s6-notifyoncheck -w 500 -c "nc -z localhost 3389"

# set env
s6-env DISPLAY=:1

/usr/sbin/xrdp --nodaemon

# ===== From ./processed/rdesktop/root/etc/s6-overlay//s6-rc.d/svc-xrdp-sesman/run =====
#! /usr/bin/execlineb -P

# Redirect stderr to stdout.
fdmove -c 2 1

# Notify service manager when xrdp is up
s6-notifyoncheck -w 500 -c "nc -z localhost 3350"

/usr/sbin/xrdp-sesman --nodaemon

